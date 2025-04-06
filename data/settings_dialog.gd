extends Window

const THEMES : Dictionary[StringName, StringName] = {
	"default": "",
	"one_dark": "uid://bh8bmd0min05g",
	"nord": "uid://clnfuh3cw3v6b",
	"material": "uid://bnfada7k74amo",
	"green_prod": "uid://ymbk3h18s8kr",
	"dracula": "uid://d2dc175aatida",
	"dark_solarised": "uid://bhn4h7qu80ytq",
	"dark": "uid://cjiej4kk0y2t1",
	"misc1": "uid://ntnplf46rp70",
	"misc2": "uid://bip7wt8nktv7g"
}

@onready var always_on_top_check: CheckButton = %AlwaysOnTopCheck
@onready var auto_start_work_check: CheckButton = %AutoStartWorkCheck
@onready var auto_start_break_check: CheckButton = %AutoStartBreakCheck
@onready var desktop_notifications_check: CheckButton = %DesktopNotificationsCheck
@onready var minimize_to_tray_check: CheckButton = %MinimizeToTrayCheck
@onready var minimize_on_close_check: CheckButton = %MinimizeOnCloseCheck
@onready var sound_enabled_check: CheckButton = %SoundEnabledCheck
@onready var tick_sound_check: CheckButton = %TickSoundCheck
@onready var work_duration_spin: SpinBox = %WorkDurationSpin
@onready var short_break_spin: SpinBox = %ShortBreakSpin
@onready var long_break_spin: SpinBox = %LongBreakSpin
@onready var long_break_interval_spin: SpinBox = %LongBreakIntervalSpin
@onready var cover_screen_during_breaks_check: CheckButton = %CoverScreenDuringBreaksCheck
@onready var uncover_when_skipped_check: CheckButton = %UncoverWhenSkippedCheck
@onready var content_scale_spin: SpinBox = %ContentScaleSpin
@onready var tick_last_10_secs_check: CheckButton = %TickLast10SecsCheck
@onready var theme_options: OptionButton = %ThemeOptions
@onready var prevent_alt_f4_during_breaks_check : CheckButton 

func _ready() -> void:
	#Load themes into optionButton and load theme
	Settings.change_theme(Settings.theme_uid)
	populate_theme_options()
	
	# Load current settings
	always_on_top_check.button_pressed = Settings.always_on_top
	auto_start_work_check.button_pressed = Settings.auto_start_work_timer
	auto_start_break_check.button_pressed = Settings.auto_start_break_timer
	desktop_notifications_check.button_pressed = Settings.desktop_notifications
	minimize_to_tray_check.button_pressed = Settings.minimize_to_tray
	minimize_on_close_check.button_pressed = Settings.minimize_to_tray_on_close
	sound_enabled_check.button_pressed = Settings.sound_enabled
	tick_sound_check.button_pressed = Settings.tick_sound_enabled
	cover_screen_during_breaks_check.button_pressed = Settings.cover_screen_during_breaks
	uncover_when_skipped_check.button_pressed = Settings.uncover_when_skipped
	tick_last_10_secs_check.button_pressed = Settings.play_tick_sound_in_the_last_10_seconds
	content_scale_spin.value = Settings.content_size_scale
	#theme_options.selected = THEMES.theme_uid #FIXME: Fix it by using arrays instead?
	
	# Load timer settings
	var timer_settings := Settings.load_timer_settings()
	work_duration_spin.value = timer_settings.work_duration / 60
	short_break_spin.value = timer_settings.short_break_duration / 60
	long_break_spin.value = timer_settings.long_break_duration / 60
	long_break_interval_spin.value = timer_settings.long_break_interval

func _on_save_button_pressed() -> void:
	# Save general settings
	Settings.always_on_top = always_on_top_check.button_pressed
	Settings.auto_start_work_timer = auto_start_work_check.button_pressed
	Settings.auto_start_break_timer = auto_start_break_check.button_pressed
	Settings.desktop_notifications = desktop_notifications_check.button_pressed
	Settings.minimize_to_tray = minimize_to_tray_check.button_pressed
	Settings.minimize_to_tray_on_close = minimize_on_close_check.button_pressed
	Settings.sound_enabled = sound_enabled_check.button_pressed
	Settings.tick_sound_enabled = tick_sound_check.button_pressed
	Settings.cover_screen_during_breaks = cover_screen_during_breaks_check.button_pressed
	Settings.content_size_scale = content_scale_spin.value
	Settings.play_tick_sound_in_the_last_10_seconds = tick_last_10_secs_check.button_pressed
	Settings.uncover_when_skipped = uncover_when_skipped_check.button_pressed
	Settings.theme_uid = theme_options.get_selected_metadata()
	Settings.save_settings()
	
	# Save timer settings
	TimerManager.set_work_duration(work_duration_spin.value)
	TimerManager.set_short_break_duration(short_break_spin.value)
	TimerManager.set_long_break_duration(long_break_spin.value)
	TimerManager.set_long_break_interval(long_break_interval_spin.value)
	
	# Apply settings that need immediate effect
	Settings._apply_settings()
	
	
	
	queue_free()

func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_close_requested() -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "size", Vector2i(get_window().size*1.05), 0.025)

	#tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(get_window(), "size", Vector2i(Vector2.ZERO), 0.2)
	
	await tween.finished
	queue_free()

func populate_theme_options() -> void:
	for theme:StringName in THEMES:
		theme_options.add_item(theme)
		theme_options.set_item_metadata( theme_options.item_count - 1, THEMES[theme])


func _on_theme_options_item_selected(index: int) -> void:
	#HACK: To prevent resetting of theme is settings dialog
	if index != 0: Settings.theme_uid = theme_options.get_item_metadata(index)
