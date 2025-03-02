extends Node

# General settings
var always_on_top: bool = false
var auto_start_work_timer: bool = true
var auto_start_break_timer: bool = true
var desktop_notifications: bool = true
var minimize_to_tray: bool = true
var minimize_to_tray_on_close: bool = true
var cover_screen_during_breaks: bool = true
var uncover_when_skipped: bool = false #TODO: Implement when needed

# Sound settings
var sound_enabled: bool = true
var work_finish_sound_path: String = "res://assets/sfx/work_done.ogg"
var break_finish_sound_path: String = "res://assets/sfx/work_done.ogg"
var tick_sound_enabled: bool = false
var tick_sound_path: String = "res://assets/sfx/tick-tock.ogg"

# Config file paths
const SETTINGS_PATH = "user://settings.cfg"
const TIMER_SETTINGS_PATH = "user://timer_settings.cfg"

func _ready() -> void:
	load_settings()
	_apply_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	
	# General settings
	config.set_value("general", "always_on_top", always_on_top)
	config.set_value("general", "auto_start_work_timer", auto_start_work_timer)
	config.set_value("general", "auto_start_break_timer", auto_start_break_timer)
	config.set_value("general", "desktop_notifications", desktop_notifications)
	config.set_value("general", "minimize_to_tray", minimize_to_tray)
	config.set_value("general", "minimize_to_tray_on_close", minimize_to_tray_on_close)
	config.set_value("general", "cover_screen_during_breaks", cover_screen_during_breaks)
	
	# Sound settings
	config.set_value("sound", "sound_enabled", sound_enabled)
	config.set_value("sound", "work_finish_sound_path", work_finish_sound_path)
	config.set_value("sound", "break_finish_sound_path", break_finish_sound_path)
	config.set_value("sound", "tick_sound_enabled", tick_sound_enabled)
	config.set_value("sound", "tick_sound_path", tick_sound_path)
	
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	
	if error != OK:
		# First run or file doesn't exist
		save_settings()
		return
	
	# General settings
	always_on_top = config.get_value("general", "always_on_top", always_on_top)
	auto_start_work_timer = config.get_value("general", "auto_start_work_timer", auto_start_work_timer)
	auto_start_break_timer = config.get_value("general", "auto_start_break_timer", auto_start_break_timer)
	desktop_notifications = config.get_value("general", "desktop_notifications", desktop_notifications)
	minimize_to_tray = config.get_value("general", "minimize_to_tray", minimize_to_tray)
	minimize_to_tray_on_close = config.get_value("general", "minimize_to_tray_on_close", minimize_to_tray_on_close)
	cover_screen_during_breaks = config.get_value("general", "cover_screen_during_breaks", cover_screen_during_breaks)
	
	# Sound settings
	sound_enabled = config.get_value("sound", "sound_enabled", sound_enabled)
	work_finish_sound_path = config.get_value("sound", "work_finish_sound_path", work_finish_sound_path)
	break_finish_sound_path = config.get_value("sound", "break_finish_sound_path", break_finish_sound_path)
	tick_sound_enabled = config.get_value("sound", "tick_sound_enabled", tick_sound_enabled)
	tick_sound_path = config.get_value("sound", "tick_sound_path", tick_sound_path)

func save_timer_settings(work_dur: float, short_break_dur: float, long_break_dur: float, long_break_int: int) -> void:
	var config := ConfigFile.new()
	
	config.set_value("timer", "work_duration", work_dur)
	config.set_value("timer", "short_break_duration", short_break_dur)
	config.set_value("timer", "long_break_duration", long_break_dur)
	config.set_value("timer", "long_break_interval", long_break_int)
	
	config.save(TIMER_SETTINGS_PATH)

func load_timer_settings() -> Dictionary[StringName, float]:
	var config := ConfigFile.new()
	var error := config.load(TIMER_SETTINGS_PATH)
	
	const default_work_duration : int = 25 * 60
	const default_short_break_duration : int = 5 * 60
	const default_long_break_duration : int = 15 * 60
	const default_long_break_interval : int = 4
	
	if error != OK:
		# First run or file doesn't exist
		save_timer_settings(default_work_duration, default_short_break_duration, 
							default_long_break_duration, default_long_break_interval)
		return {
			"work_duration": default_work_duration,
			"short_break_duration": default_short_break_duration,
			"long_break_duration": default_long_break_duration,
			"long_break_interval": default_long_break_interval
		}
	
	return {
		"work_duration": config.get_value("timer", "work_duration", default_work_duration),
		"short_break_duration": config.get_value("timer", "short_break_duration", default_short_break_duration),
		"long_break_duration": config.get_value("timer", "long_break_duration", default_long_break_duration),
		"long_break_interval": config.get_value("timer", "long_break_interval", default_long_break_interval)
	}

func _apply_settings() -> void:
	if always_on_top:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
