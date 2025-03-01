extends Node

signal start_timer_requested
signal silent_mode_requested(value: bool)

func _ready():
	var arguments = OS.get_cmdline_args()
	for arg in arguments:
		match arg:
			"--start-timer":
				start_timer_requested.emit.call_deferred()
				print("Hi idk why this doesnt work")
			"--silent":
				silent_mode_requested.emit.call_deferred(true)
