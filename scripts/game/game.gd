class_name Game extends Node2D

@onready var hud_handler: Node = %HUDHandler

@onready var hud_canvas: CanvasLayer = %HUDCanvas
@onready var menu_btn: StandartButton = %MenuBtn

var current_stage: Enums.GameStages = Enums.GameStages.NONE

func _ready() -> void:
	G.game = self
	
	_entry_point()

func _entry_point() -> void:
	## Точка входа
	change_stage(Enums.GameStages.GAME)

func _exit_stage() -> void:
	await get_tree().process_frame

func _enter_stage() -> void:
	match current_stage:
		Enums.GameStages.GAME:
			pass

func change_stage(new_stage: Enums.GameStages) -> void:
	if current_stage != Enums.GameStages.NONE:
		await _exit_stage()
	
	current_stage = new_stage
	_enter_stage()
