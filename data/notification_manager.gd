extends Node

var work_notification_title : StringName = tr("Work Time Finished")
var work_notification_body : StringName = tr("Time for a break! Look at something 20ft away or walk away")
var short_break_notification_title : StringName = tr("Short Break Finished")
var short_break_notification_body : StringName = tr("Back to work!")
var long_break_notification_title : StringName = tr("Long Break Finished")
var long_break_notification_body : StringName = tr("Back to work!")

func _ready() -> void:
	TimerManager.timer_finished.connect(_on_timer_finished)

func _on_timer_finished(timer_type: TimerManager.TimerType) -> void:
	if Settings.desktop_notifications and not TimerManager.silent_mode:
		match timer_type:
			TimerManager.TimerType.WORK:
				 #FIXME: Run after sound plays and before next timer
				show_notification.call_deferred(work_notification_title, work_notification_body)
			TimerManager.TimerType.SHORT_BREAK:
				show_notification.call_deferred(short_break_notification_title, short_break_notification_body)
			TimerManager.TimerType.LONG_BREAK:
				show_notification.call_deferred(long_break_notification_title, long_break_notification_body)

func show_notification(title: String, content: String) -> void:
	DisplayServer.window_request_attention() #FIXME: Use window's function or just show a smaller notification setting for ppl who dod not want a slow setting
	if OS.get_name() != "Web":
		OS.alert(content, title)
