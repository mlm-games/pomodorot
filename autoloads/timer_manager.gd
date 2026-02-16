extends Node

signal timer_updated(time_left: int, total_time: int)
signal timer_finished(timer_type: TimerType)
signal timer_started(timer_type: TimerType)
signal timer_paused
signal timer_resumed
signal timer_stopped

enum TimerType {WORK, SHORT_BREAK, LONG_BREAK}
enum TimerState {STOPPED, RUNNING, PAUSED, FINISHED}

var current_timer_type: int = TimerType.WORK
var current_state: int = TimerState.STOPPED
var timer: Timer
var time_left: float = 0.0
var total_time: float = 0.0
var is_running: bool = false
var is_paused: bool = false
var cycle_count: int = 0
var no_popups_and_sound: bool = false
var prev_window_mode: int = -1 # -1 -> “unset”
var current_break_in_series: int = 0

# Timer durations (secs)
var work_duration: int = 25 * 60
var short_break_duration: int = 5 * 60
var long_break_duration: int = 15 * 60
var long_break_interval: int = 4

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	CommandLine.no_popups_and_sound_requested.connect(_on_no_popups_and_sound_requested)
	CommandLine.start_timer_requested.connect(_on_start_timer_requested)

	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	_load_durations()
	Settings.setting_changed.connect(_on_setting_changed)

func _process(_delta: float) -> void:
	if is_running and not is_paused:
		time_left = max(timer.time_left, 0.0)
		timer_updated.emit(int(time_left), int(total_time))

func _on_setting_changed(key: String, value) -> void:
	match key:
		"work_duration":
			work_duration = int(value * 60)
		"short_break_duration":
			short_break_duration = int(value * 60)
		"long_break_duration":
			long_break_duration = int(value * 60)
		"long_break_interval":
			long_break_interval = int(value)

func start_timer(type: int = -1) -> void:
	if type != -1:
		current_timer_type = type

	match current_timer_type:
		TimerType.WORK:
			total_time = work_duration
		TimerType.SHORT_BREAK:
			total_time = short_break_duration
		TimerType.LONG_BREAK:
			total_time = long_break_duration

	time_left = total_time
	timer.start(total_time)
	is_running = true
	is_paused = false
	current_state = TimerState.RUNNING
	timer_started.emit(current_timer_type)

func pause_timer() -> void:
	if is_running and not is_paused:
		timer.paused = true
		is_paused = true
		current_state = TimerState.PAUSED
		timer_paused.emit()

func resume_timer() -> void:
	if is_running and is_paused:
		timer.paused = false
		is_paused = false
		current_state = TimerState.RUNNING
		timer_resumed.emit()

func stop_timer() -> void:
	timer.stop()
	is_running = false
	is_paused = false
	current_state = TimerState.STOPPED
	timer_stopped.emit()

func skip_timer() -> void:
	stop_timer()
	_advance_timer_type()
	start_timer()

func _on_timer_timeout() -> void:
	is_running = false
	current_state = TimerState.FINISHED

	_increment_pomodoro_count()

	timer_finished.emit(current_timer_type)

	if Settings.get_setting("auto_start_work_timer") and current_timer_type != TimerType.WORK:
		_advance_timer_type()
		start_timer()
		# Restore window state when returning from a break.
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, Settings.get_setting("always_on_top"))
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		if prev_window_mode != -1:
			DisplayServer.window_set_mode(prev_window_mode)
			prev_window_mode = -1

	elif Settings.get_setting("auto_start_break_timer") and current_timer_type == TimerType.WORK:
		_advance_timer_type()
		start_timer()
		DisplayServer.window_move_to_foreground()

		if Settings.get_setting("cover_screen_during_breaks"):
			# Save previous mode once when entering break
			prev_window_mode = DisplayServer.window_get_mode()
			if prev_window_mode == DisplayServer.WINDOW_MODE_MINIMIZED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

			DisplayServer.window_set_mode.call_deferred(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag.call_deferred(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)

			var root_win := get_tree().root
			if root_win and not root_win.has_focus():
				root_win.grab_focus.call_deferred()

func _advance_timer_type() -> void:
	match current_timer_type:
		TimerType.WORK:
			cycle_count += 1
			if cycle_count >= long_break_interval:
				current_timer_type = TimerType.LONG_BREAK
				cycle_count = 0
				current_break_in_series = 0  # Reset after long break
			else:
				current_timer_type = TimerType.SHORT_BREAK
				current_break_in_series = cycle_count  # 1, 2, 3...
		TimerType.SHORT_BREAK, TimerType.LONG_BREAK:
			current_timer_type = TimerType.WORK

func reset_cycle_count() -> void:
	if not is_running:
		cycle_count = 0
		current_break_in_series = 0
		current_timer_type = TimerType.WORK

func _increment_pomodoro_count() -> void:
	if current_timer_type == TimerType.WORK:
		var current_count = Settings.get_setting("pomodoro_count")
		Settings.set_setting("pomodoro_count", current_count + 1)
		# autosave handles it (unless disabled).

func _load_durations() -> void:
	work_duration = int(Settings.get_setting("work_duration") * 60)
	short_break_duration = int(Settings.get_setting("short_break_duration") * 60)
	long_break_duration = int(Settings.get_setting("long_break_duration") * 60)
	long_break_interval = int(Settings.get_setting("long_break_interval"))

func _on_no_popups_and_sound_requested(value: bool) -> void:
	no_popups_and_sound = value

func _on_start_timer_requested() -> void:
	start_timer(TimerType.WORK)
