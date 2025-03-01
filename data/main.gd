extends Control

@onready var time_label = $VBoxContainer/TimeLabel
@onready var status_label = $VBoxContainer/StatusLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var start_pause_button = $VBoxContainer/HBoxContainer/StartPauseButton
@onready var stop_button = $VBoxContainer/HBoxContainer/StopButton
@onready var skip_button = $VBoxContainer/HBoxContainer/SkipButton

var notification_manager: Node
var sound_manager: Node

func _ready():
	# Initialize managers
	notification_manager = preload("res://data/notification_manager.gd").new()
	add_child(notification_manager)
	
	sound_manager = preload("res://data/sound_manager.gd").new()
	add_child(sound_manager)
	
	# Connect signals
	TimerManager.timer_updated.connect(_on_timer_updated)
	TimerManager.timer_started.connect(_on_timer_started)
	TimerManager.timer_finished.connect(_on_timer_finished)
	TimerManager.timer_paused.connect(_on_timer_paused)
	TimerManager.timer_resumed.connect(_on_timer_resumed)
	TimerManager.timer_stopped.connect(_on_timer_stopped)
	
	# Setup initial UI state
	_update_ui(0, 0)
	_set_timer_inactive_state()

func _on_timer_updated(time_left, total_time):
	_update_ui(time_left, total_time)

func _on_timer_started(timer_type):
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

func _on_timer_finished(_timer_type):
	_set_timer_inactive_state()

func _on_timer_paused():
	start_pause_button.text = "Resume"

func _on_timer_resumed():
	start_pause_button.text = "Pause"

func _on_timer_stopped():
	_set_timer_inactive_state()

func _update_ui(time_left, total_time):
	# Update time display
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Update progress bar
	if total_time > 0:
		progress_bar.value = (time_left / total_time) * 100
	else:
		progress_bar.value = 0

func _set_timer_inactive_state():
	start_pause_button.text = "Start"
	stop_button.disabled = true
	skip_button.disabled = true

func _on_start_pause_button_pressed():
	if not TimerManager.is_running:
		TimerManager.start_timer()
	elif TimerManager.is_paused:
		TimerManager.resume_timer()
	else:
		TimerManager.pause_timer()

func _on_stop_button_pressed():
	TimerManager.stop_timer()

func _on_skip_button_pressed():
	TimerManager.skip_timer()

func _on_settings_button_pressed():
	var settings_dialog = preload("res://data/settings_dialog.tscn").instantiate()
	add_child(settings_dialog)
	settings_dialog.popup_centered()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Settings.minimize_to_tray_on_close:
			pass
			#TODO: Implement tray functionality here and prevent window from quitting
			# For now, just hide the window
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
			#hide()
		else:
			get_tree().quit()
