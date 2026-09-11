extends Node

#region Money
signal money_changed(value: float)

func add_money(add_value: float) -> void:
	Platform.save_value("money", Platform.player_data.money + add_value)
	money_changed.emit(Platform.player_data.money)

func take_money(take_value: float) -> void:
	Platform.save_value("money", Platform.player_data.money - take_value)
	money_changed.emit(Platform.player_data.money)

#endregion
