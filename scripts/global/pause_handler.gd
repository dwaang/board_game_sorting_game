extends Node

@export var pause_game_on_unfocus: bool = true
@export var mute_audio_on_unfocus: bool = true

var is_paused: bool = false
var is_forced_muted: bool = false

func _ready() -> void:
	if not Platform.data_provider:
		await Events.provider_ready
		
	Platform.data_provider.pause_requested.connect(_on_platform_pause_requested)
	Platform.data_provider.mute_requested.connect(_on_platform_mute_requested)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_handle_focus_loss()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_handle_focus_gain()

func _handle_focus_loss() -> void:
	if pause_game_on_unfocus:
		pause_game()
	if mute_audio_on_unfocus:
		force_mute_audio(true)

func _handle_focus_gain() -> void:
	if mute_audio_on_unfocus:
		force_mute_audio(false)

# Реакция на события от WebSDK (вкладку скрыли/показали)
func _on_platform_pause_requested(platform_paused: bool) -> void:
	if platform_paused:
		_handle_focus_loss()
	else:
		_handle_focus_gain()

func _on_platform_mute_requested(platform_muted: bool) -> void:
	force_mute_audio(platform_muted)

func pause_game() -> void:
	if is_paused: return
	is_paused = true
	get_tree().paused = true
	
	if is_instance_valid(G.pause_menu):
		G.pause_menu.open_menu()

func resume_game() -> void:
	if not is_paused: return
	is_paused = false
	get_tree().paused = false
	
	if is_instance_valid(G.pause_menu):
		G.pause_menu.close_menu()

func force_mute_audio(mute: bool) -> void:
	is_forced_muted = mute
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, is_forced_muted)
