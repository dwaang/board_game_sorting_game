extends Node

var current_stage: Enums.GlobalStages = Enums.GlobalStages.NONE

func _exit_stage() -> void:
	await get_tree().process_frame

func _enter_stage() -> void:
	match current_stage:
		Enums.GlobalStages.MAIN_MENU:
			var new_main_menu: MainMenu = Refs.main_menu_scene.instantiate()
			G.main.add_stage_node(new_main_menu)
			
			Platform.set_gameplay(false)
		
		Enums.GlobalStages.GAME:
			var new_game: Game = Refs.game_scene.instantiate()
			
			new_game.ready.connect(
				func():
					Platform.set_gameplay(true)
			)
			
			G.main.add_stage_node(new_game)

func change_stage(new_stage: Enums.GlobalStages) -> void:
	if current_stage != Enums.GlobalStages.NONE:
		await _exit_stage()
	
	current_stage = new_stage
	_enter_stage()
