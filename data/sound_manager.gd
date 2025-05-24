extends Node

var audio_player: AudioStreamPlayer

func _ready() -> void:
	TimerManager.timer_finished.connect(_on_timer_finished)
	TimerManager.timer_updated.connect(_on_timer_updated)
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	Settings.setting_changed.connect(_on_setting_changed)
	
	_load_sounds()

func _load_sounds() -> void:
	var work_finish_path : StringName = Settings.get_setting("work_finish_sound_path")
	var break_finish_path : StringName = Settings.get_setting("break_finish_sound_path")
	var tick_path : StringName = Settings.get_setting("tick_sound_path")
	
	if work_finish_path and ResourceLoader.exists(work_finish_path):
		work_finish_sound = load(work_finish_path)
	
	if break_finish_path and ResourceLoader.exists(break_finish_path):
		break_finish_sound = load(break_finish_path)
	
	if tick_path and ResourceLoader.exists(tick_path):
		tick_sound = load(tick_path)

var work_finish_sound: AudioStream
var break_finish_sound: AudioStream
var tick_sound: AudioStream

func _on_setting_changed(key: String, value: Variant) -> void:
	match key:
		"work_finish_sound_path":
			if ResourceLoader.exists(value):
				work_finish_sound = load(value)
		"break_finish_sound_path":
			if ResourceLoader.exists(value):
				break_finish_sound = load(value)
		"tick_sound_path":
			if ResourceLoader.exists(value):
				tick_sound = load(value)

func _on_timer_finished(timer_type: TimerManager.TimerType) -> void:
	if Settings.get_setting("sound_enabled") and not TimerManager.no_popups_and_sound:
		match timer_type:
			TimerManager.TimerType.WORK:
				if work_finish_sound:
					audio_player.stream = work_finish_sound
					audio_player.play()
			TimerManager.TimerType.SHORT_BREAK, TimerManager.TimerType.LONG_BREAK:
				if break_finish_sound:
					audio_player.stream = break_finish_sound
					audio_player.play()

func _on_timer_updated(time_left: int, _total_time: int) -> void:
	if Settings.get_setting("sound_enabled") and Settings.get_setting("tick_sound_enabled") and not TimerManager.no_popups_and_sound \
	and TimerManager.current_timer_type == TimerManager.TimerType.WORK:
		var should_play_tick := false
		
		if Settings.get_setting("play_tick_sound_in_the_last_10_seconds"):
			should_play_tick = time_left <= 10 and fmod(time_left, 1.0) < 0.05 and time_left > 0
		else:
			should_play_tick = fmod(time_left, 1.0) < 0.05 and time_left > 0
		
		if should_play_tick and tick_sound:
			if not audio_player.stream == tick_sound:
				audio_player.stream = tick_sound
			if not audio_player.playing:
				audio_player.play()
