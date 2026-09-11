class_name SkillNode
extends Node2D

# --- Настройки узла (Инспектор) ---
@export_group("Title")
@export var title: String = "Название"
@export_group("Effect Value")
@export var stat_name: String
@export var effect_value: Variant
@export var effect_value_add_symbol: String = ""
@export_group("Cost")
@export var cost_type: Enums.ValuesTypes
@export var base_cost: int = 3
@export var cost_growth_rate: float = 0.5
@export var cost_add_symbol: String = "$"
@export_group("Level")
@export var max_level: int

# --- Ссылки на UI элементы ---
@onready var button: StandartButton = %Button
@onready var tooltip: SkillNodeTooltip = %SkillNodeTooltip
@onready var child_line: Line2D = %ChildLine

# --- Системные переменные ---
var level: int = 0: set = _on_level_set
var cost: int

var path_tree: NodePath
var parent_skillnode: SkillNode
var child_skills: Array[SkillNode] = []

# Первоначальная настройка связи дерева
func start_init() -> void:
	tooltip.skill_node = self
	path_tree = G.skill_tree.get_path_to(self)
	
	# Проверяем и кэшируем родительский узел
	var real_parent = get_parent()
	if real_parent is SkillNode:
		parent_skillnode = real_parent
		parent_skillnode.child_skills.append(self)
		create_line()
	
	# Загрузка уровня (автоматически вызовет сеттер уровня и посчитает цену)
	level = G.skill_tree.get_level_for_skill(path_tree)
	
	# Вместо match для одного условия используем быстрый if
	if cost_type == Enums.ValuesTypes.MONEY:
		DataHandler.money_changed.connect(_on_cost_value_changed)
		_on_cost_value_changed(Platform.player_data.money)

# --- Логика интерфейса ---
func _on_button_mouse_entered() -> void:
	tooltip._show()

func _on_button_mouse_exited() -> void:
	tooltip._hide()

# Обработка клика по кнопке прокачки
func _on_button_pressed() -> void:
	if max_level > 0 and level >= max_level: return
	
	# Кэшируем значение валюты, чтобы не дергать метод дважды
	var current_currency = Platform.player_data.get_value_from_name(Refs.values_names[cost_type])
	if current_currency >= cost:
		level_up()

# Сеттер уровня (срабатывает при изменении переменной level)
func _on_level_set(value: int) -> void:
	level = value
	cost = roundi(StatCalculator.get_scaled_value(float(base_cost), float(value + 1), cost_growth_rate))
	
	if max_level > 0 and value >= max_level:
		button.theme = Refs.max_level_skill_node_theme
		child_line.width = 20
	else:
		tooltip.update_tooltip()

# Повышение уровня и сохранение прогресса
func level_up() -> void:
	var prev_cost: int = cost
	
	if not stat_name.is_empty():
		var current_stat = Platform.player_data.get_value_from_name(stat_name)
		Platform.save_value(stat_name, current_stat + effect_value)
		
	level += 1 # Триггерит сеттер _on_level_set
	G.skill_tree.save_skill_level(path_tree, level)
	_take_cost_value(prev_cost)

# Списание стоимости апгрейда
func _take_cost_value(value: int) -> void:
	if cost_type == Enums.ValuesTypes.MONEY:
		DataHandler.take_money(value)

# Реакция на изменение денег (меняем тему кнопки доступно/недоступно)
func _on_cost_value_changed(value: int) -> void:
	if max_level > 0 and level >= max_level: return
	
	tooltip.update_tooltip()
	
	if value >= cost:
		child_line.width = 16
		child_line.default_color = Refs.enough_money_color
		button.theme = Refs.base_skill_node_theme
	else:
		child_line.width = 12
		child_line.default_color = Refs.not_enough_money_color
		button.theme = Refs.no_money_skill_node_theme

func create_line() -> void:
	if not parent_skillnode: return
	if not parent_skillnode.is_node_ready():
		await parent_skillnode.ready
	_draw_line()

func _draw_line() -> void:
	child_line.clear_points()
	child_line.add_point(Vector2.ZERO)
	child_line.add_point(to_local(parent_skillnode.global_position))

func open_child() -> void:
	for child in child_skills:
		if not child.visible:
			child.button.start_anim()
