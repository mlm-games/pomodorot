extends Node

signal timer_updated(time_left: int, total_time: int)
signal timer_finished(timer_type: TimerType)
signal timer_started(timer_type: TimerType)
signal timer_paused
signal timer_resumed
signal timer_stopped

enum TimerType {WORK, SHORT_BREAK, LONG_BREAK}

var current_timer_type: int = TimerType.WORK
var timer: Timer
var time_left: float = 0
var total_time: float = 0
var is_running: bool = false
var is_paused: bool = false
var cycle_count: int = 0
var silent_mode: bool = false
var prev_window_mode: DisplayServer.WindowMode

# Default timer durations (in seconds)
var work_duration: int = 25 * 60
var short_break_duration: int = 5 * 60
var long_break_duration: int = 15 * 60
var long_break_interval: int = 4  # After how many work sessions

func _ready() -> void:
	CommandLine.silent_mode_requested.connect(_on_silent_mode_requested)
	CommandLine.start_timer_requested.connect(_on_start_timer_requested)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Load saved durations from settings
	_load_durations()

func _process(_delta: float) -> void:
	if is_running and not is_paused:
		time_left = timer.time_left
		timer_updated.emit(time_left, total_time)

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
	timer_started.emit(current_timer_type)

func pause_timer() -> void:
	if is_running and not is_paused:
		timer.paused = true
		is_paused = true
		timer_paused.emit()

func resume_timer() -> void:
	if is_running and is_paused:
		timer.paused = false
		is_paused = false
		timer_resumed.emit()

func stop_timer() -> void:
	timer.stop()
	is_running = false
	is_paused = false
	timer_stopped.emit()

func skip_timer() -> void:
	stop_timer()
	_advance_timer_type()
	start_timer()

func _on_timer_timeout()  -> void:
	is_running = false
	timer_finished.emit(current_timer_type)
	
	if Settings.auto_start_work_timer and current_timer_type != TimerType.WORK:
		_advance_timer_type()
		start_timer()
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, Settings.always_on_top)
		if prev_window_mode: DisplayServer.window_set_mode(prev_window_mode)
	
	elif Settings.auto_start_break_timer and current_timer_type == TimerType.WORK:
		_advance_timer_type()
		start_timer()
		DisplayServer.window_move_to_foreground()
		if Settings.cover_screen_during_breaks:
			prev_window_mode = DisplayServer.window_get_mode(get_tree().get_root().get_window_id())
			print(prev_window_mode)
			#TODO: add the window changing part even for skips (or do not add as this is better when u skip impulsively?)
			if prev_window_mode == DisplayServer.WINDOW_MODE_MINIMIZED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			#if !get_window().has_focus(): get_window().grab_focus()
			DisplayServer.window_set_mode.call_deferred(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag.call_deferred(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
			 #TODO: call a redraw or screen update here, none the following worked: a#RenderingServer.force_draw()    # OS.notification(NOTIFICATION_WM_SIZE_CHANGED)  #get_tree().get_world()


func _advance_timer_type() -> void:
	match current_timer_type:
		TimerType.WORK:
			cycle_count += 1
			if cycle_count >= long_break_interval:
				current_timer_type = TimerType.LONG_BREAK
				cycle_count = 0
			else:
				current_timer_type = TimerType.SHORT_BREAK
		TimerType.SHORT_BREAK, TimerType.LONG_BREAK:
			current_timer_type = TimerType.WORK

func set_work_duration(minutes: float) -> void:
	work_duration = minutes * 60
	Settings.save_timer_settings(work_duration, short_break_duration, long_break_duration, long_break_interval)

func set_short_break_duration(minutes: float) -> void:
	short_break_duration = minutes * 60
	Settings.save_timer_settings(work_duration, short_break_duration, long_break_duration, long_break_interval)

func set_long_break_duration(minutes: float) -> void:
	long_break_duration = minutes * 60
	Settings.save_timer_settings(work_duration, short_break_duration, long_break_duration, long_break_interval)

func set_long_break_interval(cycles: int) -> void:
	long_break_interval = cycles
	Settings.save_timer_settings(work_duration, short_break_duration, long_break_duration, long_break_interval)

func _load_durations() -> void:
	var settings := Settings.load_timer_settings()
	work_duration = settings.work_duration
	short_break_duration = settings.short_break_duration
	long_break_duration = settings.long_break_duration
	long_break_interval = settings.long_break_interval

func _on_silent_mode_requested(value: bool) -> void:
	silent_mode = value

func _on_start_timer_requested() -> void:
	#print("idk why this doesnt work")
	start_timer(TimerType.WORK)
