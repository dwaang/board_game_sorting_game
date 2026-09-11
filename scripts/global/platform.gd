extends Node

@onready var steam_api: SteamAPI = %SteamAPI
@onready var data_provider: DataProvider = %DataProvider

var player_data: Data:
	get: return data_provider.player_data

var features: PlatformFeatures:
	get: return data_provider.features

func _ready() -> void:
	data_provider.data_loaded.connect(_on_data_loaded)
	data_provider.init_platform()

#region Публичные методы (Короткий доступ к ядру)

func _on_data_loaded(_success: bool) -> void:
	Events.provider_ready.emit()

func save_value(key: String, value: Variant) -> void:
	data_provider.save_value(key, value)

func unlock_achievement(ach_id: String) -> void:
	data_provider.unlock_achievement(ach_id)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_data"):
		reset_data()

func reset_data() -> void:
	data_provider.reset_data()

func change_language() -> void:
	data_provider.change_lang()

func set_gameplay(is_active: bool) -> void:
	data_provider.features.set_gameplay(is_active)

#endregion
