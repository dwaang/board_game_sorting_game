class_name MainMenu
extends CanvasLayer

#region Nodes

@onready var options_btn: StandartButton = %OptionsBtn
@onready var credits_btn: StandartButton = %CreditsBtn
@onready var quit_btn: StandartButton = %QuitBtn
@onready var game_btn: StandartButton = %GameBtn

@onready var options_panel: PanelContainer = %OptionsPanel
@onready var change_lang_btn: StandartButton = %ChangeLangBtn
@onready var volume_panel_container: PanelContainer = %VolumePanelContainer
@onready var music_h_slider: HSlider = %MusicHSlider
@onready var sfx_h_slider: HSlider = %SFXHSlider
@onready var ui_h_slider: HSlider = %UIHSlider
@onready var options_back_btn: StandartButton = %OptionsBackBtn

@onready var credits_panel: PanelContainer = %CreditsPanel
@onready var credits_back_btn: StandartButton = %CreditsBackBtn

#endregion

#region Lifecycle

func _ready() -> void:
	_set_start_volume_values()

#endregion

#region Buttons

func _enable_btns() -> void:
	options_btn.start_anim()
	credits_btn.start_anim()
	game_btn.start_anim()
	quit_btn.start_anim()
	options_back_btn.start_anim()

func _disable_btns() -> void:
	options_btn.enabled(false)
	credits_btn.enabled(false)
	game_btn.enabled(false)
	quit_btn.enabled(false)
	options_back_btn.enabled(false)

func _on_game_btn_pressed() -> void:
	_disable_btns()
	GlobalStageManager.change_stage(Enums.GlobalStages.GAME)

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_options_btn_pressed() -> void:
	_open_options()

func _on_options_back_btn_pressed() -> void:
	_close_options()

func _on_change_lang_btn_pressed() -> void:
	Platform.change_language()

func _on_credits_btn_pressed() -> void:
	_open_credits()

func _on_credits_back_btn_pressed() -> void:
	_close_credits()

#endregion

#region Options

func _open_options() -> void:
	_set_start_volume_values()
	_disable_btns()
	options_panel.show()
	
	var tween := create_tween()
	options_panel.offset_transform_scale = Vector2.ZERO
	options_panel.modulate.a = 0.0
	tween.tween_property(options_panel, "offset_transform_scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(options_panel, "modulate:a", 1.0, 0.1)
	tween.finished.connect(
		func():
			options_back_btn.start_anim()
	)

func _close_options() -> void:
	_disable_btns()
	
	var tween := create_tween()
	tween.tween_property(options_panel, "offset_transform_scale", Vector2.ZERO, 0.15)
	tween.parallel().tween_property(options_panel, "modulate:a", 0.0, 0.15)
	tween.finished.connect(
		func():
			_enable_btns()
			options_panel.hide()
	)

#endregion

#region Credits

func _open_credits() -> void:
	_disable_btns()
	credits_panel.show()
	
	var tween := create_tween()
	credits_panel.offset_transform_scale = Vector2.ZERO
	credits_panel.modulate.a = 0.0
	tween.tween_property(credits_panel, "offset_transform_scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(credits_panel, "modulate:a", 1.0, 0.1)
	tween.finished.connect(
		func():
			credits_back_btn.start_anim()
	)

func _close_credits() -> void:
	_disable_btns()
	
	var tween := create_tween()
	tween.tween_property(credits_panel, "offset_transform_scale", Vector2.ZERO, 0.15)
	tween.parallel().tween_property(credits_panel, "modulate:a", 0.0, 0.15)
	tween.finished.connect(
		func():
			_enable_btns()
			credits_panel.hide()
	)

#endregion

#region Volume

func _set_start_volume_values() -> void:
	music_h_slider.value = Platform.player_data.music_volume
	sfx_h_slider.value = Platform.player_data.sfx_volume
	ui_h_slider.value = Platform.player_data.ui_volume
	
	_on_music_h_slider_value_changed(music_h_slider.value)
	_on_sfxh_slider_value_changed(sfx_h_slider.value)
	_on_uih_slider_value_changed(ui_h_slider.value)

func _on_music_h_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0.0)
	
	if Platform.player_data.music_volume != value:
		Platform.save_value("music_volume", value)

func _on_sfxh_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0.0)
	
	if Platform.player_data.sfx_volume != value:
		Platform.save_value("sfx_volume", value)


func _on_uih_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("UI")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0.0)
	
	if Platform.player_data.ui_volume != value:
		Platform.save_value("ui_volume", value)

#endregion
