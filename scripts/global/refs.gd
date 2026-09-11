extends Node

@export_group("Scnes")
@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene

@export_group("Themes")
@export var base_skill_node_theme: Theme
@export var no_money_skill_node_theme: Theme
@export var max_level_skill_node_theme: Theme

@export_group("UI")
@export_subgroup("Colors")
@export var not_enough_money_color: Color
@export var enough_money_color: Color

@export_group("Data")
@export var values_names: Array[String]
@export var values_sprites: Array[CompressedTexture2D]

const ACH_DATAS: Array[Dictionary] = [
	{"tag": "ACH_FIRST_LAUNCH", "name_ru": "Здравствуй, мир!", "desc_ru": "Первый запуск игры."},
	{"tag": "ACH_MINUTE_TEN", "name_ru": "Разминка", "desc_ru": "Провести в игре 10 минут."},
	{"tag": "ACH_HOUR_ONE", "name_ru": "Первый час", "desc_ru": "Провести в игре 1 час."},
	{"tag": "ACH_HOUR_TWO", "name_ru": "Уже не вернуть", "desc_ru": "Провести в игре более 2-ух часов."},
	{"tag": "ACH_STREAK_2", "name_ru": "Два дня подряд", "desc_ru": "Запустить игру 2 дня подряд."},
	{"tag": "ACH_STREAK_3", "name_ru": "Три дня подряд", "desc_ru": "Запустить игру 3 дня подряд."},
	{"tag": "ACH_RESTART_MASTER", "name_ru": "Не упал!", "desc_ru": "Перезапустить игру 5 раз."},
	{"tag": "ACH_ALL_ACHS", "name_ru": "Платина", "desc_ru": "Получить все ачивки."}
]
