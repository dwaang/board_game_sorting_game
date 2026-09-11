class_name PlatformProvider
extends Node

signal data_loaded(success: bool)
signal ad_finished(success: bool)
signal authorization_completed(success: bool)
signal pause_requested(is_paused: bool)
signal mute_requested(is_muted: bool)
signal leaderboard_entries_loaded(success: bool, entries: Array)

func init_platform() -> void: pass
func authorize_player() -> void: pass
func save_value(_key: String, _value: Variant) -> void: pass
func load_save() -> void: pass
func show_interstitial(_placement: String = "interstitial") -> void: pass
func show_rewarded(_placement: String = "rewarded") -> void: pass
func get_entries_leaderboard(_leaderboard_id: String) -> void: pass
func set_leaderboard(_leaderboard_id: String, _new_score: Variant) -> void: pass
func unlock_achievement(_ach_id: String) -> void: pass
