extends Node


const SETTINGS_METADATA : Dictionary[StringName, Dictionary] = {
	# General settings
	always_on_top = {
		"type": "bool", "default": false, "section": "general", 
		"label": "Always On Top",
		"description": "Keeps the window above other applications",
		"platforms": ["windows", "linux", "macos"]
	},
	auto_start_work_timer = {
		"type": "bool", "default": true, "section": "general", 
		"label": "Auto-start Work Timer",
		"description": "Automatically starts the work timer after a break ends"
	},
	auto_start_break_timer = {
		"type": "bool", "default": true, "section": "general", 
		"label": "Auto-start Break Timer",
		"description": "Automatically starts a break timer after work ends"
	},
	desktop_notifications = {
		"type": "bool", "default": true, "section": "general", 
		"label": "Desktop Notifications",
		"description": "Shows notifications when timers end"
	},
	minimize_to_tray = {
		"type": "bool", "default": true, "section": "general", 
		"label": "Minimize to Tray",
		"description": "Allows minimizing to system tray",
		"platforms": ["windows", "linux", "macos"]
	},
	minimize_to_tray_on_close = {
		"type": "bool", "default": true, "section": "general", 
		"label": "Minimize to Tray on Close",
		"description": "Minimizes to tray instead of closing when the close button is clicked",
		"platforms": ["windows", "linux", "macos"]
	},
	cover_screen_during_breaks = {
		"type": "bool", "default": true, "section": "general", 
		"label": "Cover Screen During Breaks",
		"description": "Maximizes the application during breaks to encourage taking a break"
	},
	theme_uid = {
		"type": "option", "default": "", "section": "general", "label": "Theme",
		"description": "Visual appearance of the app",
		"options": {
			"default": "", "one_dark": "uid://bh8bmd0min05g", "nord": "uid://clnfuh3cw3v6b",
			"material": "uid://bnfada7k74amo", "green_prod": "uid://ymbk3h18s8kr", "dracula": "uid://d2dc175aatida",
			"dark_solarised": "uid://bhn4h7qu80ytq", "dark": "uid://cjiej4kk0y2t1", "modern_with_shadows_and_inter": "uid://bqm8k7n3x4p2t"
		}
	},
	uncover_when_skipped = {
		"type": "bool", "default": false, "section": "general", "advanced": true,
		"label": "Allow Uncovering When Skipped",
		"description": "Returns to normal window size when a break is skipped"
	},
	prevent_alt_f4_close = {
		"type": "bool", "default": false, "section": "general", "advanced": true,
		"label": "Prevent Alt+F4 Close",
		"description": "Prevents closing the app with Alt+F4",
		"platforms": ["windows", "linux", "macos"]
	},
	show_percentage_instead_of_time = {
		"type": "bool", "default": false, "section": "general", "advanced": true,
		"label": "Show Percentage Instead of Time",
		"description": "Display progress as percentage rather than remaining time"
	},
	hide_seconds_display = {
		"type": "bool", "default": false, "section": "general", "advanced": true,
		"label": "Hide Seconds (Minutes Only)",
		"description": "Show only minutes in the timer display"
	},
	show_pomodoro_counter = {
		"type": "bool", "default": false, "section": "general", "advanced": true,
		"label": "Show Pomodoro Counter",
		"description": "Display count of completed pomodoro sessions"
	},
	play_tick_sound_in_the_last_10_seconds = {
		"type": "bool", "default": false, "section": "general", "advanced": true,
		"label": "Play Tick Sound For Last 10 Seconds",
		"description": "Only plays the tick sound during the final countdown"
	},
	content_scale_factor = {
		"type": "float", "default": 1.0, "section": "general", "advanced": true,
		"label": "Screen Content Scale",
		"description": "Adjusts the size of UI elements",
		"min": 0.1, "max": 10.0, "step": 0.05
	},
	pomodoro_count = {
		"type": "int", "default": 0, "section": "general", "hidden": true,
		"label": "Pomodoro Count", "description": "Number of completed pomodoro sessions"
	},
	window_position = {
		"type": "vector2i", "default": Vector2i(-1, -1), "section": "internal", "hidden": true,
		"label": "Window Position", "description": "Last saved window position. (-1, -1) means centered."
	},
	window_size = {
		"type": "vector2i", "default": Vector2i(-1, -1), "section": "internal", "hidden": true,
		"label": "Window Size", "description": "Last saved window size. (-1, -1) means default."
 	},
	
	# Sound settings
	sound_enabled = {
		"type": "bool", "default": true, "section": "sound", 
		"label": "Sound Enabled",
		"description": "Enables or disables all sounds"
	},
	tick_sound_enabled = {
		"type": "bool", "default": false, "section": "sound", 
		"label": "Tick Sound",
		"description": "Plays a ticking sound during timers"
	},
	work_finish_sound_path = {
		"type": "file", "default": "res://assets/sfx/work_done.ogg", "section": "sound", "advanced": true,
		"label": "Work Finish Sound",
		"description": "Sound played when work timer ends",
		"file_filter": "*.ogg,*.wav"
	},
	break_finish_sound_path = {
		"type": "file", "default": "res://assets/sfx/work_done.ogg", "section": "sound", "advanced": true,
		"label": "Break Finish Sound",
		"description": "Sound played when break timer ends",
		"file_filter": "*.ogg,*.wav"
	},
	tick_sound_path = {
		"type": "file", "default": "res://assets/sfx/tick-tock.wav", "section": "sound", "advanced": true,
		"label": "Tick Sound File",
		"description": "Sound file for the ticking sound",
		"file_filter": "*.ogg,*.wav",
		"depends_on": "tick_sound_enabled"
	},
	
	# Timer settings
	work_duration = {
		"type": "float", "default": 25.0, "section": "timer",
		"label": "Work Duration (minutes)", "description": "Length of work sessions",
		"min": 1.0, "max": 120.0, "step": 1.0
	},
	short_break_duration = {
		"type": "float", "default": 5.0, "section": "timer",
		"label": "Short Break (minutes)", "description": "Length of short breaks",
		"min": 1.0, "max": 30.0, "step": 1.0
	},
	long_break_duration = {
		"type": "float", "default": 15.0, "section": "timer",
		"label": "Long Break (minutes)", "description": "Length of long breaks",
		"min": 1.0, "max": 60.0, "step": 1.0
	},
	long_break_interval = {
		"type": "int", "default": 4, "section": "timer",
		"label": "Long Break After (cycles)", "description": "Number of work sessions before a long break",
		"min": 1, "max": 10, "step": 1
	},
	autosave_enabled = {
	"type": "bool", "default": true, "section": "general",
	"label": "Autosave Settings",
	"description": "Automatically save settings when changed"
	},
}


const SETTINGS_PATH = "user://settings.cfg"

var values = {}
signal setting_changed(key, value)

func _init() -> void:
	for key in SETTINGS_METADATA:
		values[key] = SETTINGS_METADATA[key].default
	
	var os_name := OS.get_name().to_lower()
	if (os_name == "android" or os_name == "web") and not FileAccess.file_exists(SETTINGS_PATH):
		values["content_scale_factor"] = 2

func _ready() -> void:
	load_settings()
	_apply_settings()

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
		save_settings() # Save defaults on first run
		return
	for key in SETTINGS_METADATA:
		var metadata = SETTINGS_METADATA[key]
		values[key] = config.get_value(metadata.section, key, metadata.default)

func _apply_settings() -> void:
	var on_top_supported = OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linux")
	if on_top_supported:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, values.always_on_top)

	if OS.has_feature("pc"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode != DisplayServer.WINDOW_MODE_MAXIMIZED and current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
			if values.window_size != Vector2i(-1, -1):
				DisplayServer.window_set_size(values.window_size)
			if values.window_position != Vector2i(-1, -1):
				DisplayServer.window_set_position(values.window_position)
			else:
				var screen_size = DisplayServer.screen_get_size()
				var window_size = DisplayServer.window_get_size()
				DisplayServer.window_set_position(screen_size / 2 - window_size / 2)

	get_tree().root.set_content_scale_factor(values.content_scale_factor)
	change_theme(values.theme_uid)

func get_setting(key: String):
	return values[key]

func set_setting(key: String, value):
	values[key] = value
	setting_changed.emit(key, value)
	
	# Autosave if enabled (but don't autosave the autosave setting)
	if values.get("autosave_enabled", true) and key != "autosave_enabled":
		save_settings()

func save_window_state():
	if OS.has_feature("pc"):
		var current_mode = DisplayServer.window_get_mode()
		# Only save position/size if window is in normal windowed mode (to prevent maximised being the only size)
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			set_setting("window_position", DisplayServer.window_get_position())
			set_setting("window_size", DisplayServer.window_get_size())
			save_settings()
	

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
