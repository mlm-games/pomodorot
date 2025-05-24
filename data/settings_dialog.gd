extends Window

@onready var general_container := %GeneralSettings
@onready var sound_container := %SoundSettings
@onready var timer_container := %TimerSettings

# Store created controls by setting key for easy access
var setting_controls := {}

func _ready() -> void:
	# Auto-generate settings UI instead of manually adding 4 times for every entry
	generate_settings_ui()
	
	if Settings.get_setting("theme_uid") != "":
		self.theme = load(Settings.get_setting("theme_uid"))

func generate_settings_ui() -> void:
	# Clear existing children
	for container:Container in [general_container, sound_container, timer_container]:
		for child:Control in container.get_children():
			child.queue_free()
	
	for key:StringName in Settings.SETTINGS_METADATA:
		var metadata := Settings.SETTINGS_METADATA[key]
		var container := _get_container_for_section(metadata.section)
		
		if container == null:
			continue
		
		var control := _create_control_for_setting(key, metadata)
		if control:
			container.add_child(control)
			setting_controls[key] = control

func _get_container_for_section(section: String) -> Control:
	match section:
		"general": return general_container
		"sound": return sound_container
		"timer": return timer_container
	return null

func _create_control_for_setting(key: String, metadata: Dictionary) -> Control:
	var current_value : Variant = Settings.get_setting(key)
	
	match metadata.type:
		"bool":
			return _create_bool_setting(key, metadata, current_value)
		"float", "int":
			return _create_numeric_setting(key, metadata, current_value)
		"option":
			return _create_option_setting(key, metadata, current_value)
		"file":
			return _create_file_setting(key, metadata, current_value)
	
	return null

func _create_bool_setting(key: String, metadata: Dictionary, current_value: Variant) -> Control:
	var check := CheckButton.new()
	check.text = metadata.label
	check.tooltip_text = metadata.description if "description" in metadata else ""
	check.button_pressed = current_value
	
	check.toggled.connect(_on_bool_setting_changed.bind(key))
	
	return check

func _create_numeric_setting(key: String, metadata: Dictionary, current_value: Variant) -> Control:
	var container := HBoxContainer.new()
	
	var label := Label.new()
	label.text = metadata.label + ":"
	label.tooltip_text = metadata.description if "description" in metadata else ""
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var spin := SpinBox.new()
	spin.min_value = metadata.min if "min" in metadata else 0
	spin.max_value = metadata.max if "max" in metadata else 100
	spin.step = metadata.step if "step" in metadata else 1
	spin.value = current_value
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	spin.value_changed.connect(_on_numeric_setting_changed.bind(key))
	
	container.add_child(label)
	container.add_child(spin)
	
	return container

func _create_option_setting(key: String, metadata: Dictionary, current_value: Variant) -> Control:
	var container := HBoxContainer.new()
	
	var label := Label.new()
	label.text = metadata.label + ":"
	label.tooltip_text = metadata.description if "description" in metadata else ""
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var selected_idx := 0
	var idx := 0
	for option_key:StringName in metadata.options:
		var option_value : Variant = metadata.options[option_key]
		option.add_item(option_key)
		option.set_item_metadata(idx, option_value)
		
		if option_value == current_value:
			selected_idx = idx
		
		idx += 1
	option.select(selected_idx)
	
	option.item_selected.connect(_on_option_setting_changed.bind(key))
	
	container.add_child(label)
	container.add_child(option)
	
	return container

func _create_file_setting(key: String, metadata: Dictionary, current_value: Variant) -> Control:
	var container := HBoxContainer.new()
	
	var label := Label.new()
	label.text = metadata.label + ":"
	label.tooltip_text = metadata.description if "description" in metadata else ""
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var line_edit := LineEdit.new()
	line_edit.text = current_value
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var browse_button := Button.new()
	browse_button.text = "..."
	browse_button.pressed.connect(_on_browse_file_pressed.bind(key, metadata, line_edit))
	
	line_edit.text_changed.connect(_on_file_setting_changed.bind(key))
	
	container.add_child(label)
	container.add_child(line_edit)
	container.add_child(browse_button)
	
	return container

func _on_bool_setting_changed(value: bool, key: String) -> void:
	Settings.set_setting(key, value)

func _on_numeric_setting_changed(value: float, key: String) -> void:
	Settings.set_setting(key, value)

func _on_option_setting_changed(index: int, key: String) -> void:
	var option_button : OptionButton = setting_controls[key].get_child("OptionButton")
	var value : Variant = option_button.get_item_metadata(index)
	Settings.set_setting(key, value)

func _on_file_setting_changed(value: String, key: String) -> void:
	Settings.set_setting(key, value)

func _on_browse_file_pressed(key: String, metadata: Dictionary, line_edit: LineEdit) -> void:
	var file_dialog := FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	
	if "file_filter" in metadata:
		file_dialog.filters = [metadata.file_filter]
	
	file_dialog.file_selected.connect(func(path:String) -> void: 
		line_edit.text = path
		Settings.set_setting(key, path)
	)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_save_button_pressed() -> void:
	Settings.save_settings()
	
	Settings._apply_settings()
	
	queue_free()

func _on_cancel_button_pressed() -> void:
	# Revert any changes automatically by reloading settings
	Settings.load_settings()
	Settings._apply_settings()
	
	queue_free()

func _on_close_requested() -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "size", Vector2i(get_window().size*1.05), 0.025)
	tween.tween_property(get_window(), "size", Vector2i(Vector2.ZERO), 0.2)
	
	await tween.finished
	queue_free()
