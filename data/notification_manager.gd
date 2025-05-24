extends Node

const NOTIFICATIONS = {
	TimerManager.TimerType.WORK: {
		"title": "Work Time Finished",
		"body": "Time for a break! Look at something 20ft away or walk away"
	},
	TimerManager.TimerType.SHORT_BREAK: {
		"title": "Short Break Finished", 
		"body": "Back to work!"
	},
	TimerManager.TimerType.LONG_BREAK: {
		"title": "Long Break Finished", 
		"body": "Back to work!"
	}
}

func _ready() -> void:
	TimerManager.timer_finished.connect(_on_timer_finished)

func _on_timer_finished(timer_type: TimerManager.TimerType) -> void:
	if Settings.get_setting("desktop_notifications") and not TimerManager.no_popups_and_sound:
		if timer_type in NOTIFICATIONS:
			var notif : Dictionary = NOTIFICATIONS[timer_type]
			show_notification_and_grab_focus(notif.title, notif.body)

func show_notification_and_grab_focus(title: String, content: String) -> void:
	DisplayServer.window_request_attention()
	if OS.get_name() != "Web":
		OS.alert(content, title)
	get_tree().get_root().grab_focus()
