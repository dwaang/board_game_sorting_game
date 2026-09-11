class_name HUDHandler
extends Node

@onready var menu_btn: StandartButton = %MenuBtn

func _on_menu_btn_pressed() -> void:
	G.pause_menu.open_menu()
