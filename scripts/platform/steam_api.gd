class_name SteamAPI
extends Node

@export var app_id: String = "480"
@export var is_active: bool = false

var is_running: bool = false
var steam_id: int = 0
var username: String = "Player"
var time_check_timer: Timer

func _init() -> void:
	OS.set_environment("SteamAppID", app_id)
	OS.set_environment("SteamGameID", app_id)

func _ready() -> void:
	initialize_steam()

func initialize_steam() -> void:
	if not is_active: return
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var init_result: Dictionary = Steam.steamInitEx(false)
	if init_result.status != 0:
		push_warning("Steam API: Ошибка инициализации (Статус: %d)." % init_result.status)
		return
	
	is_running = Steam.isSteamRunning()
	if not is_running:
		push_warning("Steam: Клиент не запущен.")
		return
		
	steam_id = Steam.getSteamID()
	username = Steam.getFriendPersonaName(steam_id)
	print("✅ Steam запущен: %s (ID: %s)" % [username, steam_id])
	
	Events.data_loaded.connect(_on_data_loaded)
	Platform.data_provider.achievement_unlocked.connect(_on_achievement_unlocked_in_game)
	
	# Запускаем таймер игрового времени
	time_check_timer = Timer.new()
	time_check_timer.wait_time = 60.0
	time_check_timer.timeout.connect(_on_time_check_timeout)
	add_child(time_check_timer)

func _on_data_loaded() -> void:
	if not is_running: return
	_check_start_achievements()
	time_check_timer.start()

func _on_time_check_timeout() -> void:
	if not is_running or Platform.player_data == null: return
	
	var new_total_time_minute: int = Platform.player_data.total_time_minute + 1
	Platform.save_value("total_time_minute", new_total_time_minute)
	
	if new_total_time_minute >= 10: Platform.unlock_achievement("ACH_MINUTE_TEN")
	if new_total_time_minute >= 60: Platform.unlock_achievement("ACH_HOUR_ONE")
	if new_total_time_minute > 120: Platform.unlock_achievement("ACH_HOUR_TWO")

func _on_achievement_unlocked_in_game(ach_id: String) -> void:
	if not is_running: return
	
	var status: Dictionary = Steam.getAchievement(ach_id)
	if not status.get("ret", false):
		push_warning("Steam: Ачивка '%s' не найдена в Steamworks!" % ach_id)
		return
		
	if Steam.setAchievement(ach_id):
		Steam.storeStats()
		print("🏆 Steam API: Ачивка '%s' отправлена в Steam." % ach_id)
		
		var target_achs_count = Refs.ACH_DATAS.filter(func(ach): return ach.tag != "ACH_ALL_ACHS").size()
		if Platform.player_data.total_achs >= target_achs_count:
			Platform.unlock_achievement("ACH_ALL_ACHS")
	else:
		push_warning("Steam: Не удалось сохранить ачивку '%s'." % ach_id)

func _check_start_achievements() -> void:
	if Platform.player_data == null: return
	
	Platform.unlock_achievement("ACH_FIRST_LAUNCH")
	if Platform.player_data.total_start_count >= 5: Platform.unlock_achievement("ACH_RESTART_MASTER")
	if Platform.player_data.login_streak >= 2: Platform.unlock_achievement("ACH_STREAK_2")
	if Platform.player_data.login_streak >= 3: Platform.unlock_achievement("ACH_STREAK_3")
