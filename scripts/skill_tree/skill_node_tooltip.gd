class_name SkillNodeTooltip
extends Control

@onready var title_label: RichTextLabel = %TitleLabel
@onready var effect_value_label: RichTextLabel = %EffectValueLabel
@onready var cost_button: StandartButton = %CostButton
@onready var cost_label: RichTextLabel = %CostLabel
@onready var progress_bar: ProgressBar = %ProgressBar

var skill_node: SkillNode

var scale_tween: Tween
var mod_tween: Tween

func _ready() -> void:
	modulate.a = 0.0

func _show() -> void:
	update_tooltip()
	show()
	scale = Vector2.ZERO
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.05)
	scale_tween.tween_property(self, "scale", Vector2.ONE * 0.9, 0.1)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.15)
	
	if mod_tween and mod_tween.is_running(): mod_tween.kill()
	mod_tween = create_tween()
	mod_tween.tween_property(self, "modulate:a", 1.0, 0.15)

func _hide() -> void:
	if scale_tween and scale_tween.is_running(): scale_tween.kill()
	scale_tween = create_tween()
	var rate: float = maxf(scale.x / Vector2.ONE.x, scale.y / Vector2.ONE.y)
	scale_tween.tween_property(self, "scale", Vector2.ZERO, 0.15 * rate)
	
	if mod_tween and mod_tween.is_running(): mod_tween.kill()
	mod_tween = create_tween()
	mod_tween.tween_property(self, "modulate:a", 0.0, 0.05 * rate).set_delay(0.05 * rate)

func update_tooltip() -> void:
	var title: String = tr(skill_node.title)
	var effect_value = skill_node.effect_value
	var effect_value_add_symbol: String = skill_node.effect_value_add_symbol
	var stat_name: String = skill_node.stat_name
	var cost_type: Enums.ValuesTypes = skill_node.cost_type
	var cost: int = skill_node.cost
	var cost_add_symbol: String = skill_node.cost_add_symbol
	var level: int = skill_node.level
	var max_level: int = skill_node.max_level
	
	if title:
		title_label.text = skill_node.title
		title_label.show()
	else:
		title_label.hide()
	
	if effect_value and stat_name:
		var cur_value = Platform.player_data.get_value_from_name(stat_name)
		var format_cur_value: String = FormatNumber.get_format_number(cur_value)
		if max_level > 0 and level >= max_level:
			effect_value_label.text = str(format_cur_value, effect_value_add_symbol)
		else:
			var format_next_value: String = FormatNumber.get_format_number(cur_value + effect_value)
			effect_value_label.text = str(format_cur_value, effect_value_add_symbol, " => ", format_next_value, effect_value_add_symbol)
		effect_value_label.show()
	else:
		effect_value_label.hide()
	
	if cost:
		cost_button.icon = Refs.values_sprites[cost_type]
		cost_label.text = str(FormatNumber.get_format_number(cost), cost_add_symbol)
		
		if Platform.player_data.money >= cost:
			cost_label.modulate = Color(0.522, 0.733, 0.396, 1.0)
			cost_button.disabled = false
		else:
			cost_label.modulate = Color(0.729, 0.365, 0.365, 1.0)
			cost_button.disabled = true
		
		cost_button.show()
	else:
		cost_button.hide()
	
	progress_bar.max_value = max_level
	progress_bar.value = level
