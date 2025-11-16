extends Control

@onready var time_label: Label = %TimeLabel
@onready var status_label: Label = %StatusLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var start_pause_button: Button = %StartPauseButton
@onready var stop_button: Button = %StopButton
@onready var skip_button: Button = %SkipButton
@onready var reset_button: Button = %ResetButton

@onready var counter_label: Label = %CounterLabel

var notification_manager: Node

func _ready() -> void:
	# HACK: Settings are now loaded and applied automatically by the Settings singleton.

	notification_manager = preload("uid://dfsq5txsl3uwg").new()
	add_child(notification_manager)

	TimerManager.timer_updated.connect(_on_timer_updated)
	TimerManager.timer_started.connect(_on_timer_started)
	TimerManager.timer_finished.connect(_on_timer_finished)
	TimerManager.timer_paused.connect(_on_timer_paused)
	TimerManager.timer_resumed.connect(_on_timer_resumed)
	TimerManager.timer_stopped.connect(_on_timer_stopped)

	# Connect to setting changes to update UI elements that depend on them.
	Settings.setting_changed.connect(_on_setting_changed)

	_update_ui(0, 0)
	_set_timer_inactive_state()
	_update_counter_visibility()


func _on_setting_changed(key: String, _value) -> void:
	match key:
		"show_percentage_instead_of_time", "hide_seconds_display":
			_update_ui(TimerManager.time_left, TimerManager.total_time)
		"show_pomodoro_counter", "pomodoro_count":
			_update_counter_visibility()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed():
		return

	match event.keycode:
		KEY_SPACE:
			_on_start_pause_button_pressed()
			get_viewport().set_input_as_handled()
		KEY_S:
			if not stop_button.disabled:
				_on_stop_button_pressed()
				get_viewport().set_input_as_handled()
		KEY_N:
			if not skip_button.disabled:
				_on_skip_button_pressed()
				get_viewport().set_input_as_handled()
		KEY_R:
			if not reset_button.disabled:
				_on_reset_button_pressed()
				get_viewport().set_input_as_handled()

func _on_timer_updated(time_left: int, total_time: int) -> void:
	_update_ui(time_left, total_time)

func _on_timer_started(timer_type: TimerManager.TimerType) -> void:
	var work_color = Color.from_string("#66bb6a", Color.GREEN) #TODO: Delegate to theme later
	var break_color = Color.from_string("#42a5f5", Color.BLUE) 

	match timer_type:
		TimerManager.TimerType.WORK:
			status_label.text = "Working"
			progress_bar.self_modulate = work_color
		TimerManager.TimerType.SHORT_BREAK:
			var break_num = TimerManager.current_break_in_series
			var total_breaks = TimerManager.long_break_interval - 1
			status_label.text = "Short Break %d/%d" % [break_num, total_breaks]
			progress_bar.self_modulate = break_color
		TimerManager.TimerType.LONG_BREAK:
			status_label.text = "Long Break"
			progress_bar.self_modulate = break_color

	start_pause_button.text = "Pause"
	stop_button.disabled = false
	skip_button.disabled = false
	reset_button.disabled = true

func _on_timer_finished(_timer_type: TimerManager.TimerType) -> void:
	_set_timer_inactive_state()

func _on_timer_paused() -> void:
	start_pause_button.text = "Resume"

func _on_timer_resumed() -> void:
	start_pause_button.text = "Pause"

func _on_timer_stopped() -> void:
	_set_timer_inactive_state()
	_update_ui(0, 0)

func _update_ui(time_left: int, total_time: int) -> void:
	if Settings.get_setting("show_percentage_instead_of_time"):
		if total_time > 0:
			var percentage = ((total_time - time_left) / float(total_time)) * 100.0
			time_label.text = "%.0f%%" % percentage
		else:
			time_label.text = "0%"
	else:
		var minutes := int(time_left / 60)
		var seconds := int(time_left % 60)

		if Settings.get_setting("hide_seconds_display"):
			time_label.text = "%d min" % int(ceil(time_left / 60.0))
		else:
			time_label.text = "%02d:%02d" % [minutes, seconds]

	if total_time > 0:
		progress_bar.value = ((total_time - time_left) / float(total_time)) * 100.0
	else:
		progress_bar.value = 100.0

func _update_counter_visibility() -> void:
	# Update counter display
	if Settings.get_setting("show_pomodoro_counter"):
		counter_label.visible = true
		counter_label.text = "Pomodoros: %d" % Settings.get_setting("pomodoro_count")
	else:
		counter_label.visible = false

func _set_timer_inactive_state() -> void:
	start_pause_button.text = "Start"
	status_label.text = "Ready"
	stop_button.disabled = true
	skip_button.disabled = true
	reset_button.disabled = false

func _on_start_pause_button_pressed() -> void:
	if not TimerManager.is_running:
		TimerManager.start_timer()
	elif TimerManager.is_paused:
		TimerManager.resume_timer()
	else:
		TimerManager.pause_timer()

func _on_stop_button_pressed() -> void:
	TimerManager.stop_timer()

func _on_skip_button_pressed() -> void:
	TimerManager.skip_timer()

func _on_reset_button_pressed() -> void:
	TimerManager.reset_cycle_count()
	status_label.text = "Cycle Reset"
	_update_ui(0, 0)
	progress_bar.self_modulate = Color.WHITE

func _on_settings_button_pressed() -> void:
	var settings_dialog := preload("res://data/settings_dialog.tscn").instantiate()
	add_child(settings_dialog)
	if settings_dialog.has_meta("overlay_node"):
		settings_dialog.overlay_node = %ModalOverlay
	settings_dialog.popup_animated()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			Settings.save_window_state() # Save window state on close

			if Settings.get_setting("prevent_alt_f4_close"):
				get_tree().auto_accept_quit = false
				return

			var minimize_on_close = Settings.get_setting("minimize_to_tray_on_close")
			var tray_supported = OS.has_feature("windows") or OS.has_feature("linux") or OS.has_feature("macos")

			if minimize_on_close and tray_supported:
				get_window().hide()
			else:
				get_tree().quit()

		NOTIFICATION_WM_GO_BACK_REQUEST:
			get_tree().quit()
