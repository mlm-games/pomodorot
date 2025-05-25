extends Control

@onready var counter_label: Label = $CounterLabel
@onready var reset_button: Button = $ResetButton

func _ready() -> void:
	Settings.setting_changed.connect(_on_setting_changed)
	_update_display()

func _on_setting_changed(key: String, _value: Variant) -> void:
	if key == "pomodoro_count":
		_update_display()

func _update_display() -> void:
	counter_label.text = "Completed: %d" % Settings.get_setting("pomodoro_count")

func _on_reset_button_pressed() -> void:
	Settings.set_setting("pomodoro_count", 0)
	Settings.save_settings()
