class_name Data
extends Resource

#region Serialize Data
@export_group("Serializefield")

@export_subgroup("Game")

@export_subgroup("Player")
@export var money: int = 0
@export var unlocked_achievements: Array[String] = []

#endregion

#region System Data
@export_group("System Data (Do Not Touch)")

@export var skill_levels: Dictionary = {}

@export var last_lang_idx: int = 0

@export var music_volume: float = 0.5
@export var sfx_volume: float = 0.5
@export var ui_volume: float = 0.5

@export var total_time_minute: int = 0
@export var total_start_count: int = 0
@export var login_streak: int = 0
@export var total_achs: int = 0

#endregion

const BLACKLIST := [
	"resource_path", "resource_local_to_scene", "resource_name",
	"script", "metadata/_custom_type_script"
]

var _cached_props: Array = []
var _prop_names: Dictionary = {}
var _cache_built: bool = false

func _build_cache() -> void:
	_cached_props.clear()
	_prop_names.clear()
	
	for p in get_property_list():
		if p.usage & PROPERTY_USAGE_STORAGE and p.name not in BLACKLIST and not p.name.begins_with("__"):
			_cached_props.append(p)
			_prop_names[p.name] = true
	
	_cached_props.sort_custom(func(a, b): return a.name < b.name)
	_cache_built = true

# Конвертация в Array для сохранения (теперь с JSON-строками для веба)
func to_array() -> Array:
	if not _cache_built: _build_cache()
	
	var data = []
	for p in _cached_props:
		var value = get(p.name)
		# Превращаем массивы и словари в JSON-строки, чтобы JS в вебе не сделал их undefined
		if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
			data.append(JSON.stringify(value))
		else:
			data.append(value)
	return data

# Получить массив с названиями переменных (строго в том же порядке, что и значения)
func get_array_with_names() -> Array[String]:
	if not _cache_built: _build_cache()
	
	var names: Array[String] = []
	for p in _cached_props:
		names.append(p.name)
	return names

# Конвертировать загруженный массив обратно в переменные
func from_array(data: Array) -> void:
	if not _cache_built: _build_cache()
	
	for i in mini(data.size(), _cached_props.size()):
		var p = _cached_props[i]
		var value = data[i]

		var current_type = typeof(get(p.name))

		# Восстанавливаем словари и массивы из JSON-строки
		if value is String and current_type in [TYPE_ARRAY, TYPE_DICTIONARY]:
			var parsed = JSON.parse_string(value)
			if parsed != null:
				value = parsed

		# Безопасное и точное присвоение типов
		if current_type == TYPE_ARRAY and value is Array:
			var target = get(p.name)
			target.clear()
			target.assign(value)
		elif current_type == TYPE_DICTIONARY and value is Dictionary:
			var target = get(p.name)
			target.clear()
			for key in value:
				target[key] = value[key]
		else:
			set(p.name, value)

		print("✅ %s = %s" % [p.name, get(p.name)])

func get_value_from_name(stat_name: String) -> Variant:
	if not _cache_built: _build_cache()
	if _prop_names.has(stat_name):
		return get(stat_name)
	return null
