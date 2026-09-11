class_name Main extends Node2D

@onready var main_bg_canvas: CanvasLayer = %MainBgCanvas
@onready var main_bg_color_rect: ColorRect = %MainBgColorRect

@onready var crt_canvas: CanvasLayer = %CRTCanvas
@onready var crt_color_rect: ColorRect = %CRTColorRect

@onready var world_environment: WorldEnvironment = %WorldEnvironment

@onready var main_camera: Camera = %MainCamera

var current_stage_node: Node

func _ready() -> void:
	Events.all_is_init.connect(entry_point)
	
	G.main_camera = main_camera
	G.main = self

func entry_point() -> void:
	## Точка входа!
	GlobalStageManager.change_stage(Enums.GlobalStages.MAIN_MENU)

func add_stage_node(node: Node) -> void:
	if is_instance_valid(current_stage_node): destroy_stage_node()
	current_stage_node = node
	add_child(node)

func destroy_stage_node() -> void:
	current_stage_node.call_deferred("queue_free")
