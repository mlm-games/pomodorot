extends Node

signal start_timer_requested
signal silent_mode_requested(value: bool)

func _ready() -> void:
	var arguments : = OS.get_cmdline_args()
	for arg: StringName in arguments:
		match arg:
			"--start-timer":
				start_timer_requested.emit.call_deferred()
				print("Hi idk why this doesnt work")
			"--silent":
				silent_mode_requested.emit.call_deferred(true)
