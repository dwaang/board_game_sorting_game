class_name SkillTree
extends Node2D

@export var main_skillnode: SkillNode
@export var keyboard_speed: float = 300.0

var skill_nodes: Array[Node]

# Переменные для перетаскивания мышкой
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_start_node_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	G.skill_tree = self
	skill_nodes = get_tree().get_nodes_in_group("skillnodes")

func _process(delta: float) -> void:
	if not main_skillnode: return
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		main_skillnode.position += input_dir * keyboard_speed * delta

func _input(event: InputEvent) -> void:
	if not main_skillnode: return
	if event.is_action("left_mouse") or event.is_action("middle_mouse") or event.is_action("right_mouse"):
		is_pressed_check(event.pressed)
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_current_pos = get_global_mouse_position()
		var mouse_delta = mouse_current_pos - drag_start_mouse_pos
		main_skillnode.position = drag_start_node_pos + mouse_delta

func is_pressed_check(pressed: bool) -> void:
	is_dragging = pressed
	if is_dragging:
		drag_start_mouse_pos = get_global_mouse_position()
		drag_start_node_pos = main_skillnode.position

func initialize_all_skillnodes() -> void:
	for skill in skill_nodes:
		if skill is SkillNode: skill.start_init()

func get_level_for_skill(path: NodePath) -> int:
	var data: Dictionary = Platform.player_data.skill_levels
	var str_path := str(path)
	if data.has(str_path):
		return data.get(str_path)
	return 0

func save_skill_level(path: NodePath, level: int) -> void:
	var data: Dictionary = Platform.player_data.skill_levels
	var str_path := str(path)
	data[str_path] = level
	Platform.save_value("skill_levels", data)
