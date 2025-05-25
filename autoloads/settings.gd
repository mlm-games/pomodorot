extends Node


const SETTINGS_METADATA : Dictionary[StringName, Dictionary] = {
	# General settings
	"always_on_top": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Always On Top",
		"description": "Keeps the window above other applications"
	},
	"auto_start_work_timer": {
		"type": "bool", 
		"default": true, 
		"section": "general", 
		"label": "Auto-start Work Timer",
		"description": "Automatically starts the work timer after a break ends"
	},
	"auto_start_break_timer": {
		"type": "bool", 
		"default": true, 
		"section": "general", 
		"label": "Auto-start Break Timer",
		"description": "Automatically starts a break timer after work ends"
	},
	"desktop_notifications": {
		"type": "bool", 
		"default": true, 
		"section": "general", 
		"label": "Desktop Notifications",
		"description": "Shows notifications when timers end"
	},
	"minimize_to_tray": {
		"type": "bool", 
		"default": true, 
		"section": "general", 
		"label": "Minimize to Tray",
		"description": "Allows minimizing to system tray",
		"platforms": ["Windows", "Linux", "macOS"]  # Not applicable on mobile/web, should probably handle this as a condn.
	},
	"minimize_to_tray_on_close": {
		"type": "bool", 
		"default": true, 
		"section": "general", 
		"label": "Minimize to Tray on Close",
		"description": "Minimizes to tray instead of closing when the close button is clicked",
		"platforms": ["Windows", "Linux", "macOS"]
	},
	"cover_screen_during_breaks": {
		"type": "bool", 
		"default": true, 
		"section": "general", 
		"label": "Cover Screen During Breaks",
		"description": "Maximizes the application during breaks to encourage taking a break"
	},
	"uncover_when_skipped": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Allow Uncovering When Skipped",
		"description": "Returns to normal window size when a break is skipped"
	},
	"prevent_alt_f4_close": {
	"type": "bool", 
	"default": false, 
	"section": "general", 
	"label": "Prevent Alt+F4 Close",
	"description": "Prevents closing the app with Alt+F4",
	"platforms": ["Windows", "Linux", "macOS"]
	},
	"show_percentage_instead_of_time": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Show Percentage Instead of Time",
		"description": "Display progress as percentage rather than remaining time"
	},
	"hide_seconds_display": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Hide Seconds (Minutes Only)",
		"description": "Show only minutes in the timer display"
	},
	"show_pomodoro_counter": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Show Pomodoro Counter",
		"description": "Display count of completed pomodoro sessions"
	},
	"android_background_mode": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Android Background Mode",
		"description": "Allow app to run in background on Android",
		"platforms": ["Android"]
	},
	"play_tick_sound_in_the_last_10_seconds": {
		"type": "bool", 
		"default": false, 
		"section": "general", 
		"label": "Play Tick Sound For Last 10 Seconds",
		"description": "Only plays the tick sound during the final countdown"
	},
	"content_size_scale": {
		"type": "float", 
		"default": 1.0, 
		"section": "general", 
		"label": "Screen Content Scale",
		"description": "Adjusts the size of UI elements",
		"min": 0.1,
		"max": 10.0,
		"step": 0.05
	},
		"pomodoro_count": {
		"type": "int", 
		"default": 0, 
		"section": "general", 
		"label": "Pomodoro Count",
		"description": "Number of completed pomodoro sessions",
		"hidden": true  #TODO? Don't show in UI, just store the value
	},
	"theme_uid": {
		"type": "option", 
		"default": "", 
		"section": "general", 
		"label": "Theme",
		"description": "Visual appearance of the app",
		"options": {
			"default": "",
			"one_dark": "uid://bh8bmd0min05g",
			"nord": "uid://clnfuh3cw3v6b",
			"material": "uid://bnfada7k74amo",
			"green_prod": "uid://ymbk3h18s8kr",
			"dracula": "uid://d2dc175aatida",
			"dark_solarised": "uid://bhn4h7qu80ytq",
			"dark": "uid://cjiej4kk0y2t1",
			"modern_with_shadows_and_inter": "uid://bqm8k7n3x4p2t"
		}
	},
	
	# Sound settings
	"sound_enabled": {
		"type": "bool", 
		"default": true, 
		"section": "sound", 
		"label": "Sound Enabled",
		"description": "Enables or disables all sounds"
	},
	"work_finish_sound_path": {
		"type": "file", 
		"default": "res://assets/sfx/work_done.ogg", 
		"section": "sound", 
		"label": "Work Finish Sound",
		"description": "Sound played when work timer ends",
		"file_filter": "*.ogg,*.wav"
	},
	"break_finish_sound_path": {
		"type": "file", 
		"default": "res://assets/sfx/work_done.ogg", 
		"section": "sound", 
		"label": "Break Finish Sound",
		"description": "Sound played when break timer ends",
		"file_filter": "*.ogg,*.wav"
	},
	"tick_sound_enabled": {
		"type": "bool", 
		"default": false, 
		"section": "sound", 
		"label": "Tick Sound",
		"description": "Plays a ticking sound during timers"
	},
	"tick_sound_path": {
		"type": "file", 
		"default": "res://assets/sfx/tick-tock.ogg", 
		"section": "sound", 
		"label": "Tick Sound File",
		"description": "Sound file for the ticking sound",
		"file_filter": "*.ogg,*.wav",
		"depends_on": "tick_sound_enabled"
	},
	
	# Timer settings
	"work_duration": {
		"type": "float", 
		"default": 25.0, 
		"section": "timer", 
		"label": "Work Duration (minutes)",
		"description": "Length of work sessions",
		"min": 1.0,
		"max": 120.0,
		"step": 1.0
	},
	"short_break_duration": {
		"type": "float", 
		"default": 5.0, 
		"section": "timer", 
		"label": "Short Break (minutes)",
		"description": "Length of short breaks",
		"min": 1.0,
		"max": 30.0,
		"step": 1.0
	},
	"long_break_duration": {
		"type": "float", 
		"default": 15.0, 
		"section": "timer", 
		"label": "Long Break (minutes)",
		"description": "Length of long breaks",
		"min": 1.0,
		"max": 60.0,
		"step": 1.0
	},
	"long_break_interval": {
		"type": "int", 
		"default": 4, 
		"section": "timer", 
		"label": "Long Break After (cycles)",
		"description": "Number of work sessions before a long break",
		"min": 1,
		"max": 10,
		"step": 1
	}
}


const SETTINGS_PATH = "user://settings.cfg"
const TIMER_SETTINGS_PATH = "user://timer_settings.cfg"

var values = {}

func _init() -> void:
	for key in SETTINGS_METADATA:
		values[key] = SETTINGS_METADATA[key].default
	
	if (OS.get_name() == "Android" or OS.get_name() == "Web") and !FileAccess.file_exists(SETTINGS_PATH):
		values["content_size_scale"] = 2

func save_settings() -> void:
	var config = ConfigFile.new()
	
	for key in values:
		var metadata = SETTINGS_METADATA[key]
		config.set_value(metadata.section, key, values[key])
	
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_PATH)
	
	if error != OK:
		save_settings()
		return
	
	for key in SETTINGS_METADATA:
		var metadata = SETTINGS_METADATA[key]
		values[key] = config.get_value(metadata.section, key, metadata.default)
		
func _apply_settings() -> void:
	# Apply immediate effects
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, values.always_on_top)
	get_tree().root.set_content_scale_factor(values.content_size_scale)
	change_theme(values.theme_uid)

signal setting_changed(key, value)

func get_setting(key: String):
	return values[key]
	
func set_setting(key: String, value):
	values[key] = value
	setting_changed.emit(key, value)



#
#
## General settings
#var always_on_top: bool = false
#var auto_start_work_timer: bool = true
#var auto_start_break_timer: bool = true
#var desktop_notifications: bool = true
#var minimize_to_tray: bool = true
#var minimize_to_tray_on_close: bool = true
#var cover_screen_during_breaks: bool = true
#var uncover_when_skipped: bool = false #TODO: Implement when needed
#var play_tick_sound_in_the_last_10_seconds: bool = false #TODO: If you would want to close the work or pause before the screen gets blocked only when needed
#var content_size_scale: float = 1
#var theme_uid: StringName = ""
#
## Sound settings
#var sound_enabled: bool = true
#var work_finish_sound_path: String = "res://assets/sfx/work_done.ogg"
#var break_finish_sound_path: String = "res://assets/sfx/work_done.ogg"
#var tick_sound_enabled: bool = false
#var tick_sound_path: String = "res://assets/sfx/tick-tock.ogg"
#
## Config file paths
#const SETTINGS_PATH = "user://settings.cfg"
#const TIMER_SETTINGS_PATH = "user://timer_settings.cfg"
#
#func _init() -> void:
	#if (OS.get_name() == "Android" or OS.get_name() == "Web") and !FileAccess.file_exists(SETTINGS_PATH):
		#content_size_scale = 2
#
#func _ready() -> void:
	#load_settings()
	#_apply_settings()
	#
#
#func save_settings() -> void:
	#var config := ConfigFile.new()
	#
	## General settings
	#config.set_value("general", "always_on_top", always_on_top)
	#config.set_value("general", "auto_start_work_timer", auto_start_work_timer)
	#config.set_value("general", "auto_start_break_timer", auto_start_break_timer)
	#config.set_value("general", "desktop_notifications", desktop_notifications)
	#config.set_value("general", "minimize_to_tray", minimize_to_tray)
	#config.set_value("general", "minimize_to_tray_on_close", minimize_to_tray_on_close)
	#config.set_value("general", "cover_screen_during_breaks", cover_screen_during_breaks)
	#config.set_value("general", "uncover_when_skipped", uncover_when_skipped)
	#config.set_value("general", "play_tick_sound_in_the_last_10_seconds", play_tick_sound_in_the_last_10_seconds)
	#config.set_value("general", "content_size_scale", content_size_scale)
	#config.set_value("general", "theme", theme_uid)
	#
	## Sound settings
	#config.set_value("sound", "sound_enabled", sound_enabled)
	#config.set_value("sound", "work_finish_sound_path", work_finish_sound_path)
	#config.set_value("sound", "break_finish_sound_path", break_finish_sound_path)
	#config.set_value("sound", "tick_sound_enabled", tick_sound_enabled)
	#config.set_value("sound", "tick_sound_path", tick_sound_path)
	#
	#config.save(SETTINGS_PATH)
#
#func load_settings() -> void:
	#var config := ConfigFile.new()
	#var error := config.load(SETTINGS_PATH)
	#
	#if error != OK:
		## First run or file doesn't exist
		#
		#save_settings()
		#return
	#
	## General settings
	#always_on_top = config.get_value("general", "always_on_top", always_on_top)
	#auto_start_work_timer = config.get_value("general", "auto_start_work_timer", auto_start_work_timer)
	#auto_start_break_timer = config.get_value("general", "auto_start_break_timer", auto_start_break_timer)
	#desktop_notifications = config.get_value("general", "desktop_notifications", desktop_notifications)
	#minimize_to_tray = config.get_value("general", "minimize_to_tray", minimize_to_tray)
	#minimize_to_tray_on_close = config.get_value("general", "minimize_to_tray_on_close", minimize_to_tray_on_close)
	#cover_screen_during_breaks = config.get_value("general", "cover_screen_during_breaks", cover_screen_during_breaks)
	#uncover_when_skipped = config.get_value("general", "uncover_when_skipped", uncover_when_skipped)
	#play_tick_sound_in_the_last_10_seconds = config.get_value("general", "play_tick_sound_in_the_last_10_seconds", play_tick_sound_in_the_last_10_seconds)
	#content_size_scale  = config.get_value("general", "content_size_scale", content_size_scale)
	#theme_uid = config.get_value("general", "theme", theme_uid)
	#
	## Sound settings
	#sound_enabled = config.get_value("sound", "sound_enabled", sound_enabled)
	#work_finish_sound_path = config.get_value("sound", "work_finish_sound_path", work_finish_sound_path)
	#break_finish_sound_path = config.get_value("sound", "break_finish_sound_path", break_finish_sound_path)
	#tick_sound_enabled = config.get_value("sound", "tick_sound_enabled", tick_sound_enabled)
	#tick_sound_path = config.get_value("sound", "tick_sound_path", tick_sound_path)
#

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
#
#func _apply_settings() -> void:
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, always_on_top)
	#get_tree().root.set_content_scale_factor(content_size_scale)
	#change_theme(theme_uid)
 #


func change_theme(new_theme_uid: StringName) -> void:
	var ui_root := get_tree().root
	
	if new_theme_uid != "": 
		var new_theme := load(new_theme_uid)
		apply_theme_to_controls(ui_root, new_theme)
	else:
		clear_theme_and_make_panels_transparent()

func apply_theme_to_controls(node: Node, new_theme: Theme) -> void:
	if node is Control:
		node.theme = new_theme
		if node is Panel:
			node.self_modulate = Color.WHITE
	
	for child in node.get_children():
		apply_theme_to_controls(child, new_theme)

func clear_theme_and_make_panels_transparent() -> void:
	get_tree().root.theme = null
	
	for child in get_tree().root.get_children():
		if child is Control:
			child.theme = null
			if child is Panel:
				child.self_modulate = Color.TRANSPARENT
		
