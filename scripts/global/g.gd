extends Node

var main: Main: set = _on_main_set
var pause_menu: PauseMenu
var game: Game
var skill_tree: SkillTree
var main_camera: Camera

func _ready() -> void:
	Events.data_will_reset.connect(_on_data_will_reset)

func _on_main_set(value: Main) -> void:
	main = value
	if value:
		if not Platform.player_data: await Platform.data_loaded
		Events.all_is_init.emit()

func _on_data_will_reset() -> void:
	Events.data_reset_started.emit()
	main = null
	pause_menu = null
	game = null
	skill_tree = null
	main_camera = null
