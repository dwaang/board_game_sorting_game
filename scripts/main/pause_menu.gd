class_name PauseMenu
extends CanvasLayer

@onready var control_node: Control = %ControlNode
@onready var music_h_slider: HSlider = %MusicHSlider
@onready var sfxh_slider: HSlider = %SFXHSlider
@onready var uih_slider: HSlider = %UIHSlider
@onready var content_h_box_container: HBoxContainer = %ContentHBoxContainer

@onready var game_btn: StandartButton = %GameBtn
@onready var change_lang_btn: StandartButton = %ChangeLangBtn
@onready var quit_btn: StandartButton = %QuitBtn
@onready var main_menu_btn: StandartButton = %MainMenuBtn

var is_show: bool = false
var show_and_hide_tween: Tween

func _ready() -> void:
	G.pause_menu = self
	
	hide() 
	control_node.modulate.a = 0.0
	
	if not Platform.data_provider: await Events.provider_ready
	
	_set_start_volume_values()
	
	close_menu()

func _set_start_volume_values() -> void:
	music_h_slider.value = Platform.player_data.music_volume
	sfxh_slider.value = Platform.player_data.sfx_volume
	uih_slider.value = Platform.player_data.ui_volume
	_on_music_h_slider_value_changed(music_h_slider.value)
	_on_sfxh_slider_value_changed(sfxh_slider.value)
	_on_uih_slider_value_changed(uih_slider.value)

func toggle_menu() -> void:
	if is_show:
		PauseHandler.resume_game()
	else:
		PauseHandler.pause_game()

func open_menu() -> void:
	if is_show: return
	is_show = true
	
	_set_start_volume_values()
	
	PauseHandler.pause_game()
	
	show()
	if show_and_hide_tween and show_and_hide_tween.is_running(): show_and_hide_tween.kill()
	show_and_hide_tween = create_tween().set_parallel()
	show_and_hide_tween.tween_property(control_node, "modulate:a", 1.0, 0.3)
	show_and_hide_tween.tween_property(content_h_box_container, "scale", Vector2.ONE * 1.1, 0.2)
	show_and_hide_tween.tween_property(content_h_box_container, "scale", Vector2.ONE, 0.1).set_delay(0.2)
	show_and_hide_tween.tween_callback(_enable_btns).set_delay(0.3)
	
	if GlobalStageManager.current_stage == Enums.GlobalStages.MAIN_MENU:
		main_menu_btn.hide()
	else:
		main_menu_btn.show()

func close_menu() -> void:
	if not is_show: return
	is_show = false
	
	PauseHandler.resume_game()
	
	_disable_btns()
	if show_and_hide_tween and show_and_hide_tween.is_running(): show_and_hide_tween.kill()
	show_and_hide_tween = create_tween().set_parallel()
	show_and_hide_tween.tween_property(control_node, "modulate:a", 0.0, 0.3)
	show_and_hide_tween.tween_property(content_h_box_container, "scale", Vector2.ONE * 1.1, 0.2)
	show_and_hide_tween.tween_property(content_h_box_container, "scale", Vector2.ZERO, 0.1).set_delay(0.2)
	show_and_hide_tween.tween_callback(hide).set_delay(0.4)

func _enable_btns() -> void:
	game_btn.start_anim()
	change_lang_btn.start_anim()
	quit_btn.start_anim()

func _disable_btns() -> void:
	game_btn.end_anim()
	change_lang_btn.end_anim()
	quit_btn.end_anim()

func _on_game_btn_pressed() -> void:
	PauseHandler.resume_game()
	close_menu()

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

#region Настройки звука и языка (остаются без изменений)

func _on_music_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0.0)
	if Platform.player_data.music_volume != value:
		Platform.save_value("music_volume", value)

func _on_sfxh_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0.0)
	if Platform.player_data.sfx_volume != value:
		Platform.save_value("sfx_volume", value)

func _on_uih_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("UI")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0.0)
	if Platform.player_data.ui_volume != value:
		Platform.save_value("ui_volume", value)

func _on_change_lang_btn_pressed() -> void:
	Platform.change_language()

#endregion

func _on_main_menu_btn_pressed() -> void:
	GlobalStageManager.change_stage(Enums.GlobalStages.MAIN_MENU)
	close_menu()
