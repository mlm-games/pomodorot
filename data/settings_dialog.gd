extends Window

@onready var always_on_top_check = %AlwaysOnTopCheck
@onready var auto_start_work_check = %AutoStartWorkCheck
@onready var auto_start_break_check = %AutoStartBreakCheck
@onready var desktop_notifications_check = %DesktopNotificationsCheck
@onready var minimize_to_tray_check = %MinimizeToTrayCheck
@onready var minimize_on_close_check = %MinimizeOnCloseCheck
@onready var sound_enabled_check = %SoundEnabledCheck
@onready var tick_sound_check = %TickSoundCheck
@onready var work_duration_spin = %WorkDurationSpin
@onready var short_break_spin = %ShortBreakSpin
@onready var long_break_spin = %LongBreakSpin
@onready var long_break_interval_spin = %LongBreakIntervalSpin

func _ready():
	# Load current settings
	always_on_top_check.button_pressed = Settings.always_on_top
	auto_start_work_check.button_pressed = Settings.auto_start_work_timer
	auto_start_break_check.button_pressed = Settings.auto_start_break_timer
	desktop_notifications_check.button_pressed = Settings.desktop_notifications
	minimize_to_tray_check.button_pressed = Settings.minimize_to_tray
	minimize_on_close_check.button_pressed = Settings.minimize_to_tray_on_close
	sound_enabled_check.button_pressed = Settings.sound_enabled
	tick_sound_check.button_pressed = Settings.tick_sound_enabled
	
	# Load timer settings
	var timer_settings = Settings.load_timer_settings()
	work_duration_spin.value = timer_settings.work_duration / 60
	short_break_spin.value = timer_settings.short_break_duration / 60
	long_break_spin.value = timer_settings.long_break_duration / 60
	long_break_interval_spin.value = timer_settings.long_break_interval

func _on_save_button_pressed():
	# Save general settings
	Settings.always_on_top = always_on_top_check.button_pressed
	Settings.auto_start_work_timer = auto_start_work_check.button_pressed
	Settings.auto_start_break_timer = auto_start_break_check.button_pressed
	Settings.desktop_notifications = desktop_notifications_check.button_pressed
	Settings.minimize_to_tray = minimize_to_tray_check.button_pressed
	Settings.minimize_to_tray_on_close = minimize_on_close_check.button_pressed
	Settings.sound_enabled = sound_enabled_check.button_pressed
	Settings.tick_sound_enabled = tick_sound_check.button_pressed
	Settings.save_settings()
	
	# Save timer settings
	TimerManager.set_work_duration(work_duration_spin.value)
	TimerManager.set_short_break_duration(short_break_spin.value)
	TimerManager.set_long_break_duration(long_break_spin.value)
	TimerManager.set_long_break_interval(long_break_interval_spin.value)
	
	# Apply settings that need immediate effect
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, Settings.always_on_top)
	
	queue_free()

func _on_cancel_button_pressed():
	queue_free()


func _on_close_requested() -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "size", Vector2i(get_window().size*1.05), 0.025)

	#tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(get_window(), "size", Vector2i(Vector2.ZERO), 0.2)
	
	await tween.finished
	queue_free()
