extends Node

signal all_is_init

signal data_will_reset
signal data_reset_started

signal window_focus_entered
signal window_focus_exited
signal web_sdk_pause_state_changed(pause: bool)

signal games_paused
signal games_resumed

signal provider_ready
signal lang_changed
signal save_completed(success: bool)
signal data_loaded()

signal ad_started
signal ad_finished
signal interstitial_ad_shown
signal rewarded_ad_completed
