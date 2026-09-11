class_name StandartButton
extends Button

@export var is_start_anim: bool = true
@export var start_anim_type: Enums.BtnsStartAnimTypes
@export var end_anim_type: Enums.BtnsEndAnimTypes
@export var action_res_arr: Array[ActionRes]
@export var target_ui: Control
@export var animation_reference_size: Vector2 = Vector2(128.0, 128.0)

var scale_tween: Tween
var bounce_tween: Tween
var start_end_anim: Tween

var base_size: Vector2
var base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	if not target_ui: target_ui = self
	base_size = target_ui.size
	base_scale = target_ui.scale
	target_ui.pivot_offset_ratio = pivot_offset_ratio
	
	if is_start_anim:
		start_anim()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func enabled(value: bool) -> void:
	if value:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
		disabled = false
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		disabled = true


func get_target_scale(value: float) -> Vector2:
	var ui_size := target_ui.size
	if ui_size.x <= 0.0 or ui_size.y <= 0.0:
		return Vector2.ONE
	
	var offset := animation_reference_size * (value - 1.0)
	
	return Vector2(
		base_scale.x + offset.x / ui_size.x,
		base_scale.y + offset.y / ui_size.y
	)


func start_anim() -> void:
	if start_anim_type == Enums.BtnsStartAnimTypes.NONE: return
	
	match start_anim_type:
		Enums.BtnsStartAnimTypes.BOUNCE_SHOW:
			target_ui.show()
			if start_end_anim and start_end_anim.is_running(): start_end_anim.kill()
			start_end_anim = create_tween().set_parallel()
			target_ui.scale = Vector2.ZERO
			start_end_anim.tween_property(target_ui, "scale", get_target_scale(1.1), 0.3)
			target_ui.modulate.a = 0.0
			start_end_anim.tween_property(target_ui, "modulate:a", 1.0, 0.3)
			start_end_anim.chain().tween_callback(bounce)
		
		Enums.BtnsStartAnimTypes.BOUNCE_ENABLE:
			bounce()
			enabled(true)
		
		Enums.BtnsStartAnimTypes.BOUNCE_SHOW_ENABLE:
			target_ui.show()
			if start_end_anim and start_end_anim.is_running(): start_end_anim.kill()
			start_end_anim = create_tween().set_parallel()
			target_ui.scale = Vector2.ZERO
			start_end_anim.tween_property(target_ui, "scale", get_target_scale(1.1), 0.3)
			target_ui.modulate.a = 0.0
			start_end_anim.tween_property(target_ui, "modulate:a", 1.0, 0.3)
			start_end_anim.chain().tween_callback(func():
				enabled(true)
				bounce()
			)


func end_anim() -> void:
	if end_anim_type == Enums.BtnsEndAnimTypes.NONE: return
	
	match end_anim_type:
		Enums.BtnsEndAnimTypes.BOUNCE_DISABLE:
			bounce()
			enabled(false)
			if start_end_anim and start_end_anim.is_running(): start_end_anim.kill()
			start_end_anim = create_tween()
			start_end_anim.tween_property(target_ui, "modulate:a", 0.8, 0.2)
		
		Enums.BtnsEndAnimTypes.BOUNCE_HIDE:
			bounce()
			enabled(false)
			if start_end_anim and start_end_anim.is_running(): start_end_anim.kill()
			start_end_anim = create_tween().set_parallel()
			start_end_anim.tween_property(target_ui, "scale", Vector2.ZERO, 0.2)
			start_end_anim.tween_property(target_ui, "modulate:a", 0.0, 0.2)
			start_end_anim.chain().tween_callback(func():
				target_ui.hide()
			)


func bounce() -> void:
	if bounce_tween and bounce_tween.is_running(): bounce_tween.kill()
	bounce_tween = create_tween()
	bounce_tween.tween_property(target_ui, "scale", get_target_scale(0.9), 0.1)
	bounce_tween.tween_property(target_ui, "scale", get_target_scale(1.1), 0.1)
	bounce_tween.tween_property(target_ui, "scale", base_scale, 0.15)


func _on_mouse_entered() -> void:
	if disabled: return
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(target_ui, "scale", get_target_scale(1.15), 0.05)
	scale_tween.tween_property(target_ui, "scale", get_target_scale(0.925), 0.1)
	scale_tween.tween_property(target_ui, "scale", base_scale, 0.15)

func _on_mouse_exited() -> void:
	if disabled: return
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(target_ui, "scale", base_scale, 0.1)

func _on_pressed() -> void:
	if disabled: return
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(target_ui, "scale", get_target_scale(0.8), 0.05)
	scale_tween.tween_property(target_ui, "scale", get_target_scale(1.1), 0.05)
	scale_tween.tween_property(target_ui, "scale", get_target_scale(0.9), 0.1)
	scale_tween.tween_property(target_ui, "scale", get_target_scale(1.05), 0.1)
	scale_tween.tween_property(target_ui, "scale", base_scale, 0.15)
	
	if not action_res_arr.is_empty():
		for action in action_res_arr:
			action.action()

# SoundHandler.play_ui()

func _on_button_down() -> void:
	if disabled: return
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(target_ui, "scale", get_target_scale(0.8), 0.1)

func _on_button_up() -> void:
	if disabled: return
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(target_ui, "scale", base_scale, 0.1)
