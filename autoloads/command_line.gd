extends Node

signal start_timer_requested
signal no_popups_and_sound_requested(value: bool)

func _ready() -> void:
	var arguments : = OS.get_cmdline_args()
	for arg: StringName in arguments:
		match arg:
			"--start-timer":
				start_timer_requested.emit.call_deferred()
			"--silent":
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
			"--no-popups-and-sound":
				no_popups_and_sound_requested.emit.call_deferred(true)
	#Test stuff
	#no_popups_and_sound_requested.emit.call_deferred(true)
