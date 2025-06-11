extends Window

@onready var general_container := %GeneralSettings
@onready var sound_container := %SoundSettings
@onready var timer_container := %TimerSettings
@onready var advanced_check := %AdvancedSettingsCheck

# Store created controls by setting key for easy access
var setting_controls := {}

func _ready() -> void:
	generate_settings_ui()
	advanced_check.toggled.connect(_on_advanced_settings_toggled)
	
	# Set initial visibility based on checkbox state
	_on_advanced_settings_toggled(advanced_check.button_pressed)
	
	if Settings.get_setting("theme_uid") != "":
		self.theme = load(Settings.get_setting("theme_uid"))

func generate_settings_ui() -> void:
	# Clear any placeholder children from the editor
	for container in [general_container, sound_container, timer_container]:
		for child in container.get_children():
			child.queue_free()
	
	var current_os = OS.get_name().to_lower()

	for key in Settings.SETTINGS_METADATA:
		var metadata := Settings.SETTINGS_METADATA[key]
		
		# Skip hidden settings
		if metadata.get("hidden", false):
			continue
			
		# Skip platform-specific settings not for this platform
		if "platforms" in metadata:
			if not current_os in metadata.platforms:
				continue
		
		var container := _get_container_for_section(metadata.section)
		if not container:
			continue
		
		var control := _create_control_for_setting(key, metadata)
		if control:
			container.add_child(control)
			setting_controls[key] = control

func _on_advanced_settings_toggled(toggled_on: bool) -> void:
	for key in setting_controls:
		var metadata = Settings.SETTINGS_METADATA[key]
		if metadata.get("advanced", false):
			setting_controls[key].visible = toggled_on

func _get_container_for_section(section: String) -> VBoxContainer:
	match section:
		"general": return general_container
		"sound": return sound_container
		"timer": return timer_container
	return null

func _create_control_for_setting(key: String, metadata: Dictionary) -> Control:
	var current_value = Settings.get_setting(key)
	
	var control : Control
	match metadata.type:
		"bool":
			control = _create_bool_setting(key, metadata, current_value)
		"float", "int":
			control = _create_numeric_setting(key, metadata, current_value)
		"option":
			control = _create_option_setting(key, metadata, current_value)
		"file":
			control = _create_file_setting(key, metadata, current_value)
	
	if control and metadata.get("advanced", false):
		control.visible = false
	
	return control

func _create_bool_setting(key: String, metadata: Dictionary, current_value: Variant) -> Control:
	var check := CheckButton.new()
	check.text = metadata.label
	check.tooltip_text = metadata.get("description", "")
	check.button_pressed = current_value
	check.toggled.connect(_on_bool_setting_changed.bind(key))
	return check

func _create_numeric_setting(key: String, metadata: Dictionary, current_value: Variant) -> Control:
	var container := HBoxContainer.new()
	var label := Label.new()
	label.text = metadata.label + ":"
	label.tooltip_text = metadata.get("description", "")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var spin := SpinBox.new()
	spin.min_value = metadata.get("min", 0.0)
	spin.max_value = metadata.get("max", 100.0)
	spin.step = metadata.get("step", 1.0)
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
	label.tooltip_text = metadata.get("description", "")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var selected_idx := 0
	var idx := 0
	for option_key in metadata.options:
		var option_value = metadata.options[option_key]
		option.add_item(option_key.capitalize())
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
	label.tooltip_text = metadata.get("description", "")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var line_edit := LineEdit.new()
	line_edit.text = current_value
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var browse_button := Button.new()
	browse_button.text = "..."
	browse_button.pressed.connect(_on_browse_file_pressed.bind(key, metadata, line_edit))
	
	line_edit.text_changed.connect(Settings.set_setting.bind(key))
	
	container.add_child(label)
	container.add_child(line_edit)
	container.add_child(browse_button)
	return container

func _on_bool_setting_changed(value: bool, key: String) -> void:
	Settings.set_setting(key, value)
	# Handle dependencies, e.g., disable tick sound path if tick sound is disabled
	for setting_key in setting_controls:
		var meta = Settings.SETTINGS_METADATA[setting_key]
		if meta.get("depends_on", "") == key:
			setting_controls[setting_key].disabled = not value

func _on_numeric_setting_changed(value: float, key: String) -> void:
	var metadata = Settings.SETTINGS_METADATA[key]
	if metadata.type == "int":
		Settings.set_setting(key, int(value))
	else:
		Settings.set_setting(key, value)

func _on_option_setting_changed(index: int, key: String) -> void:
	var option_button: OptionButton = setting_controls[key].get_node("OptionButton") # Assumes structure
	var value = option_button.get_item_metadata(index)
	Settings.set_setting(key, value)

func _on_browse_file_pressed(key: String, metadata: Dictionary, line_edit: LineEdit) -> void:
	var file_dialog := FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	if "file_filter" in metadata:
		file_dialog.filters = metadata.file_filter.split(";")
	
	file_dialog.file_selected.connect(func(path: String):
		line_edit.text = path
		Settings.set_setting(key, path)
	)
	
	add_child(file_dialog)
	file_dialog.popup_centered()

func _on_save_button_pressed() -> void:
	Settings.save_settings()
	Settings._apply_settings() # Apply settings like theme, always on top, etc.
	queue_free()

func _on_cancel_button_pressed() -> void:
	# Revert any changes by reloading settings from file
	Settings.load_settings()
	Settings._apply_settings()
	queue_free()

func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_cancel_button_pressed()
