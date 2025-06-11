extends Control

@onready var time_label: Label = %TimeLabel
@onready var status_label: Label = %StatusLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var start_pause_button: Button = %StartPauseButton
@onready var stop_button: Button = %StopButton
@onready var skip_button: Button = %SkipButton

@onready var modal_overlay: ColorRect = %ModalOverlay
@onready var counter_label: Label = %CounterLabel

var notification_manager: Node
var sound_manager: Node

func _ready() -> void:
	
	if (OS.get_name() == "Android" or OS.get_name() == "Web") and !FileAccess.file_exists(Settings.SETTINGS_PATH):
		Settings.values["content_size_scale"] = 2
		Settings.save_settings()

	Settings.load_settings()
	Settings._apply_settings()
	
	notification_manager = preload("uid://dfsq5txsl3uwg").new()
	add_child(notification_manager)
	
	sound_manager = preload("uid://5nkdkcf1v2o5").new()
	add_child(sound_manager)
	
	TimerManager.timer_updated.connect(_on_timer_updated)
	TimerManager.timer_started.connect(_on_timer_started)
	TimerManager.timer_finished.connect(_on_timer_finished)
	TimerManager.timer_paused.connect(_on_timer_paused)
	TimerManager.timer_resumed.connect(_on_timer_resumed)
	TimerManager.timer_stopped.connect(_on_timer_stopped)
	
	_update_ui(0, 0)
	_set_timer_inactive_state()

func _on_timer_updated(time_left: int, total_time: int) -> void:
	_update_ui(time_left, total_time)

func _on_timer_started(timer_type: TimerManager.TimerType) -> void:
	#anim
	progress_bar.value = 0
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(progress_bar, "value", 100, 0.5).from(0)
	
	match timer_type:
		TimerManager.TimerType.WORK:
			status_label.text = "Working"
		TimerManager.TimerType.SHORT_BREAK:
			status_label.text = "Short Break"
		TimerManager.TimerType.LONG_BREAK:
			status_label.text = "Long Break"
	
	start_pause_button.text = "Pause"
	stop_button.disabled = false
	skip_button.disabled = false

func _on_timer_finished(_timer_type: TimerManager.TimerType) -> void:
	_set_timer_inactive_state()

func _on_timer_paused() -> void:
	start_pause_button.text = "Resume"

func _on_timer_resumed() -> void:
	start_pause_button.text = "Pause"

func _on_timer_stopped() -> void:
	_set_timer_inactive_state()

func _update_ui(time_left: int, total_time: int) -> void:
	if Settings.get_setting("show_percentage_instead_of_time"):
		if total_time > 0:
			var percentage = ((total_time - time_left) / float(total_time)) * 100
			time_label.text = "%.0f%%" % percentage
		else:
			time_label.text = "0%"
	else:
		var minutes := int(time_left / 60)
		var seconds := int(time_left % 60)
		
		if Settings.get_setting("hide_seconds_display"):
			time_label.text = "%d min" % minutes
		else:
			time_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Update counter display
	if Settings.get_setting("show_pomodoro_counter"):
		counter_label.visible = true
		counter_label.text = "Pomodoros: %d" % Settings.get_setting("pomodoro_count")
		_animate_counter()
	else:
		counter_label.visible = false
	
	if total_time > 0:
		progress_bar.value = (time_left / float(total_time)) * 100
	else:
		progress_bar.value = 0

func _animate_counter():
	if not counter_label.visible: return
	
	var tween = create_tween()
	tween.tween_property(counter_label, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(counter_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _set_timer_inactive_state() -> void:
	start_pause_button.text = "Start"
	stop_button.disabled = true
	skip_button.disabled = true

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

func _on_settings_button_pressed() -> void:
	var settings_dialog := preload("res://data/settings_dialog.tscn").instantiate()
	settings_dialog.overlay_node = modal_overlay
	add_child(settings_dialog)
	settings_dialog.popup_animated()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			if Settings.get_setting("prevent_alt_f4_close"):
				get_tree().auto_accept_quit = false
				return
			elif Settings.get_setting("minimize_to_tray_on_close"):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
			else:
				get_tree().quit()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			# Handle Android back button
			if OS.get_name() == "Android" and Settings.get_setting("android_background_mode"):
				# Move to background instead of closing
				OS.request_permissions()
				return
			get_tree().quit()
