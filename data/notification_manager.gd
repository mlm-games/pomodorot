extends Node

var work_notification_title = tr("Work Time Finished")
var work_notification_body = tr("Time for a break!")
var short_break_notification_title = tr("Short Break Finished")
var short_break_notification_body = tr("Back to work!")
var long_break_notification_title = tr("Long Break Finished")
var long_break_notification_body = tr("Back to work!")

func _ready():
	TimerManager.timer_finished.connect(_on_timer_finished)

func _on_timer_finished(timer_type):
	if Settings.desktop_notifications and not TimerManager.silent_mode:
		match timer_type:
			TimerManager.TimerType.WORK:
				show_notification(work_notification_title, work_notification_body)
			TimerManager.TimerType.SHORT_BREAK:
				show_notification(short_break_notification_title, short_break_notification_body)
			TimerManager.TimerType.LONG_BREAK:
				show_notification(long_break_notification_title, long_break_notification_body)

func show_notification(title: String, content: String):
	DisplayServer.window_request_attention() #FIXME: Use window's function or just show a smaller notification setting for ppl who dod not want a slow setting
	if OS.get_name() != "Web":
		OS.alert(content, title)
