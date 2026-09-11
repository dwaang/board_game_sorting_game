class_name DataProvider
extends PlatformProvider

signal achievement_unlocked(ach_id: String)

var default_save: Data = preload("uid://b07qqd4g7qsve")
var save_timer: Timer

var player_data: Data
var default_keys: Array

var langs_string: Array[String] = ["en", "ru"]
var lang_idx: int = 0

var features: PlatformFeatures

#region Инициализация

func init_platform() -> void:
	if Bridge.platform.language == "ru": lang_idx = 1
	set_lang(langs_string[lang_idx])
	
	features = PlatformFeatures.new()
	features.name = "PlatformFeatures"
	add_child(features)
	
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)

	default_keys = default_save.get_array_with_names() if default_save else []
	
	features.authorize_player(Callable(self, "load_save"))
	features.start_services()

#endregion

#region Сохранения (Ядро)

func load_save() -> void:
	Bridge.storage.get(default_keys, Callable(self, "_on_storage_get_completed"))

func _on_storage_get_completed(success: bool, data: Variant) -> void:
	player_data = default_save.duplicate(true) if default_save else Data.new()
	player_data._build_cache()
	
	if success and data != null:
		player_data.from_array(data)
		print("✅ DataProvider: Данные загружены ✅")
	else:
		print("ℹ️ DataProvider: Первый запуск или нет данных. Используем дефолт.")
	
	features.set_ready()
	
	Events.data_loaded.emit()
	data_loaded.emit(true)
	_init_saved_language()

func save_value(key: String, value: Variant) -> void:
	if player_data and key in player_data:
		player_data.set(key, value)
		if save_timer.is_stopped():
			Bridge.storage.set(default_keys, player_data.to_array(), Callable(self, "_on_storage_set_completed"))
			save_timer.start(1.0)
	else:
		push_error("В Data нет переменной: ", key)

func _on_save_timer_timeout() -> void:
	Bridge.storage.set(default_keys, player_data.to_array(), Callable(self, "_on_storage_set_completed"))

func _on_storage_set_completed(success: bool) -> void:
	Events.save_completed.emit(success)

func reset_data() -> void:
	player_data = null
	if not save_timer.is_stopped():
		save_timer.stop()
	
	Bridge.storage.delete(default_keys, Callable(self, "_on_storage_delete_completed"))

func _on_storage_delete_completed(success: bool) -> void:
	if not success:
		push_error("❌ DataProvider: Удалить данные не удалось")
	Events.data_will_reset.emit()
	player_data = default_save.duplicate(true)
	get_tree().reload_current_scene()
	load_save()

#endregion

#region Достижения

func unlock_achievement(ach_id: String) -> void:
	if player_data == null: return
	
	if player_data.unlocked_achievements.has(ach_id):
		return
	
	player_data.unlocked_achievements.append(ach_id)
	save_value("unlocked_achievements", player_data.unlocked_achievements)
	save_value("total_achs", player_data.total_achs + 1)
	
	print("✅ DataProvider: Ачивка '%s' добавлена в локальные данные." % ach_id)
	achievement_unlocked.emit(ach_id)

#endregion

#region Языки

func _init_saved_language() -> void:
	var saved_lang_idx: int = player_data.last_lang_idx
	if lang_idx != saved_lang_idx:
		lang_idx = saved_lang_idx
		set_lang(langs_string[saved_lang_idx])

func change_lang() -> void:
	lang_idx = (lang_idx + 1) % langs_string.size()
	set_lang(langs_string[lang_idx])
	save_value("last_lang_idx", lang_idx)

func set_lang(l: String) -> void:
	TranslationServer.set_locale(l)
	Events.lang_changed.emit()

#endregion

#region Делегирование фичам (Фасад)

func show_interstitial(placement := "interstitial") -> void:
	features.show_interstitial(placement)

func try_show_interstitial(placement := "interstitial") -> bool:
	return features.try_show_interstitial(placement)

func show_rewarded(placement := "rewarded") -> void:
	features.show_rewarded(placement)

func set_leaderboard(leaderboard_id: String, new_score: Variant) -> void:
	features.set_leaderboard(leaderboard_id, new_score)

func get_entries_leaderboard(leaderboard_id: String) -> void:
	features.get_entries_leaderboard(leaderboard_id)

#endregion
