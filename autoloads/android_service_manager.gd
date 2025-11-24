extends Node

const TIMER_NOTIFICATION_ID = 1001
const COMPLETION_NOTIFICATION_ID = 1002

var is_android: bool = OS.get_name() == "Android"
var notification_scheduler := NotificationScheduler.new()


func _ready() -> void:
	if is_android:
		add_child(notification_scheduler)
		
		notification_scheduler.connect("notification_opened", _on_notification_opened)
		notification_scheduler.connect("permission_granted", _on_permission_granted)
		notification_scheduler.connect("permission_denied", _on_permission_denied)
		
		if not notification_scheduler.has_post_notifications_permission():
			notification_scheduler.request_post_notifications_permission()
		
		# Create notification channel (required for Android 8.0+)
		var channel_data = NotificationChannel.new()
		channel_data.set_id("Timer").set_description("Notification for timer updates").set_importance(3).set_name("Timer Notifications")
		notification_scheduler.create_notification_channel(channel_data)
		
		TimerManager.timer_updated.connect(_on_timer_updated)
		TimerManager.timer_started.connect(_on_timer_started)
		TimerManager.timer_finished.connect(_on_timer_finished)
		TimerManager.timer_paused.connect(_on_timer_paused)
		TimerManager.timer_resumed.connect(_on_timer_resumed)
		TimerManager.timer_stopped.connect(_on_timer_stopped)
		
		Settings.setting_changed.connect(_on_setting_changed)


func _on_notification_opened(notification_id: int):
	print("Notification opened: ", notification_id)


func _on_permission_granted(permission: String):
	print("Permission granted: ", permission)


func _on_permission_denied(permission: String):
	print("Permission denied: ", permission)


func _on_timer_updated(time_left: int, total_time: int) -> void:
	if is_android and Settings.get_setting("android_persistent_notification"):
		_update_timer_notification()


func _on_timer_started(timer_type: int) -> void:
	if is_android and Settings.get_setting("android_persistent_notification"):
		_create_timer_notification()


func _on_timer_finished(timer_type: int) -> void:
	if is_android:
		if Settings.get_setting("desktop_notifications") and not TimerManager.no_popups_and_sound:
			_show_completion_notification(timer_type)
		
		if Settings.get_setting("android_persistent_notification"):
			_remove_timer_notification()


func _on_timer_paused() -> void:
	if is_android and Settings.get_setting("android_persistent_notification"):
		_update_timer_notification()


func _on_timer_resumed() -> void:
	if is_android and Settings.get_setting("android_persistent_notification"):
		_update_timer_notification()


func _on_timer_stopped() -> void:
	if is_android and Settings.get_setting("android_persistent_notification"):
		_remove_timer_notification()


func _on_setting_changed(key: String, value) -> void:
	if not is_android:
		return
		
	match key:
		"android_persistent_notification":
			if value and TimerManager.is_running:
				_create_timer_notification()
			else:
				_remove_timer_notification()


func _create_timer_notification() -> void:
	if not is_android:
		return
	
	var title = _get_timer_title()
	var content = _get_timer_content()
	
	var notification_data = NotificationData.new().set_channel_id("Timer").set_content(content).set_title(title).set_id(TIMER_NOTIFICATION_ID).set_delay(0).set_small_icon_name("ic_demo_notification")
	
	notification_scheduler.schedule(notification_data)


func _update_timer_notification() -> void:
	_create_timer_notification()  # Just recreate with updated content


func _remove_timer_notification() -> void:
	if not is_android:
		return
	
	notification_scheduler.cancel(TIMER_NOTIFICATION_ID)


func _show_completion_notification(timer_type: int) -> void:
	if not is_android:
		return
		StatusIndicator
	
	var title = ""
	var content = ""
	
	match timer_type:
		TimerManager.TimerType.WORK:
			title = "Work Time Finished"
			content = "Time for a break! Look at something 20ft away or walk away!"
		TimerManager.TimerType.SHORT_BREAK:
			title = "Short Break Finished"
			content = "Back to work!"
		TimerManager.TimerType.LONG_BREAK:
			title = "Long Break Finished"
			content = "Back to work!"
	
	var notification_data = {
		"notification_id": COMPLETION_NOTIFICATION_ID,
		"channel_id": "Timer",
		"title": title,
		"content": content,
		"small_icon_name": "ic_demo_notification",  
		"delay": 0  
	}
	
	notification_scheduler.schedule(notification_data)


func _get_timer_title() -> String:
	var title = "Pomodorot Timer"
	
	match TimerManager.current_timer_type:
		TimerManager.TimerType.WORK:
			title = "Working"
		TimerManager.TimerType.SHORT_BREAK:
			title = "Short Break"
		TimerManager.TimerType.LONG_BREAK:
			title = "Long Break"
	
	if TimerManager.is_paused:
		title += " (Paused)"
	
	return title


func _get_timer_content() -> String:
	var content = ""
	
	if TimerManager.is_running:
		var minutes = int(TimerManager.time_left / 60)
		var seconds = int(int(TimerManager.time_left) % 60)
		content = "%02d:%02d remaining" % [minutes, seconds]
	else:
		content = "Timer not running"
	
	return content
