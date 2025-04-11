extends Node

var work_finish_sound: AudioStreamOggVorbis = load(Settings.values["work_finish_sound_path"])
var break_finish_sound: AudioStreamOggVorbis = load(Settings.values["break_finish_sound_path"])
var tick_sound: AudioStreamOggVorbis = load(Settings.values["tick_sound_path"])

var audio_player: AudioStreamPlayer

func _ready() -> void:
	TimerManager.timer_finished.connect(_on_timer_finished)
	TimerManager.timer_updated.connect(_on_timer_updated)
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func _on_timer_finished(timer_type: TimerManager.TimerType) -> void:
	if Settings.sound_enabled and not TimerManager.no_popups_and_sound:
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
	if Settings.values["sound_enabled"] and Settings.values["tick_sound_enabled"] and not Settings.values["no_popups_and_sound"] \
	and TimerManager.current_timer_type == TimerManager.TimerType.WORK:
		# Play tick sound at every full second
		if fmod(time_left, 1.0) < 0.05 and time_left > 0:
			if tick_sound:
				if not audio_player.stream == tick_sound: audio_player.stream = tick_sound
				if not audio_player.playing: audio_player.play()
