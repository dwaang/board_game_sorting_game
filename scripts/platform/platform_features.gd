class_name PlatformFeatures
extends Node

signal auth_completed(success: bool)
signal ad_finished(success: bool)
signal leaderboard_loaded(success: bool, entries: Array)

var interstitial_timer: Timer
var set_leaderboard_timer: Timer

var interstitial_time: float = 240.0
var is_rewarded_sup: bool = true
var is_interstitial_sup: bool = true
var _reward_earned: bool = false

var last_leaderboard_id: String
var last_leaderboard_score: int
var is_first_set_leaderboard: bool = false

func _ready() -> void:
	_init_timers()
	_subscribe_to_bridge()

func _init_timers() -> void:
	interstitial_timer = Timer.new()
	interstitial_timer.timeout.connect(_on_interstitial_timer_timeout)
	add_child(interstitial_timer)
	
	set_leaderboard_timer = Timer.new()
	set_leaderboard_timer.one_shot = true
	set_leaderboard_timer.timeout.connect(_on_set_leaderboard_timer_timeout)
	add_child(set_leaderboard_timer)

func _subscribe_to_bridge() -> void:
	Bridge.platform.connect("pause_state_changed", Callable(self, "_on_pause_state_changed"))
	Bridge.platform.connect("audio_state_changed", Callable(self, "_on_audio_state_changed"))
	Bridge.advertisement.connect("interstitial_state_changed", Callable(self, "_on_interstitial_state_changed"))
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))

func start_services() -> void:
	if is_interstitial_sup:
		interstitial_timer.start(interstitial_time)

#region Авторизация

func authorize_player(load_save_callback: Callable) -> void:
	if not Bridge.player.is_authorization_supported or Bridge.player.is_authorized:
		load_save_callback.call()
		return
	
	Bridge.player.authorize({}, Callable(self, "_on_player_authorize_completed").bind(load_save_callback))

func _on_player_authorize_completed(success: bool, load_save_callback: Callable) -> void:
	auth_completed.emit(success)
	load_save_callback.call()

#endregion

#region Реклама (Interstitial)

func _on_interstitial_timer_timeout() -> void:
	show_interstitial()

func try_show_interstitial(placement := "interstitial") -> bool:
	if is_interstitial_sup and interstitial_timer.is_stopped():
		show_interstitial(placement)
		return true
	return false

func show_interstitial(placement := "interstitial") -> void:
	if not is_interstitial_sup:
		ad_finished.emit(false)
		return
	
	if not interstitial_timer.is_stopped(): interstitial_timer.stop()
	Events.ad_started.emit()
	Bridge.advertisement.show_interstitial(placement)

func _on_interstitial_state_changed(state: String) -> void:
	match state:
		"closed":
			Events.ad_finished.emit()
			ad_finished.emit(true)
			interstitial_timer.start(interstitial_time)
		"failed":
			Events.ad_finished.emit()
			ad_finished.emit(false)
			interstitial_timer.start(interstitial_time / 2)

#endregion

#region Реклама (Rewarded)

func show_rewarded(placement := "rewarded") -> void:
	if not is_rewarded_sup:
		Events.rewarded_ad_completed.emit(false)
		return
	
	Events.ad_started.emit()
	if interstitial_timer.paused == false: interstitial_timer.paused = true
	Bridge.advertisement.show_rewarded(placement)

func _on_rewarded_state_changed(state: String) -> void:
	match state:
		"opened": _reward_earned = false
		"rewarded": _reward_earned = true
		"closed":
			Events.rewarded_ad_completed.emit(_reward_earned)
			Events.ad_finished.emit()
			ad_finished.emit(true)
			interstitial_timer.paused = false
			interstitial_timer.start(interstitial_time / 2)
		"failed":
			Events.rewarded_ad_completed.emit(false)
			Events.ad_finished.emit()
			ad_finished.emit(false)
			interstitial_timer.paused = false

#endregion

#region Лидерборды

func set_leaderboard(leaderboard_id: String, new_score: Variant) -> void:
	last_leaderboard_id = leaderboard_id
	last_leaderboard_score = new_score
	set_leaderboard_timer.start(0.5)

func _on_set_leaderboard_timer_timeout() -> void:
	Bridge.leaderboards.set_score(last_leaderboard_id, last_leaderboard_score, Callable(self, "_on_set_leaderboard_completed"))

func _on_set_leaderboard_completed(success: bool) -> void:
	if success and not is_first_set_leaderboard:
		is_first_set_leaderboard = true
		get_entries_leaderboard(last_leaderboard_id)

func get_entries_leaderboard(leaderboard_id: String) -> void:
	Bridge.leaderboards.get_entries(leaderboard_id, Callable(self, "_on_get_entries_completed"))

func _on_get_entries_completed(success: bool, entries: Array) -> void:
	if success:
		for entry in entries:
			print("ID: " + str(entry.id) + " | Name: " + str(entry.name) + " | Score: " + str(entry.score))
	leaderboard_loaded.emit(success, entries)

#endregion

#region Фокус и Звук

func _on_pause_state_changed(is_paused: bool) -> void:
	Events.web_sdk_pause_state_changed.emit(is_paused)

func _on_audio_state_changed(is_enabled: bool) -> void:
	PauseHandler.force_mute_audio(!is_enabled)

#endregion

#region SDK Сигналы
func set_ready() -> void:
	Bridge.platform.send_message(Bridge.PlatformMessage.GAME_READY)

func set_gameplay(is_active: bool) -> void:
	match is_active:
		true:
			Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STARTED)
		false:
			Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STOPPED)

#endregion
