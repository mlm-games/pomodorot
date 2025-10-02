## Needs a platform tray GDExtension (for Linux) or run the Web build inside Electron for tray features or just use RBTray.
extends Node

func _ready() -> void:
	var si: StatusIndicator = StatusIndicator.new()
	si.icon = load("res://fastlane/metadata/android/en-US/images/icon.png")
	si.tooltip = "Pomodorot"
	si.pressed.connect(_on_si_pressed)
	add_child(si)

	var menu := PopupMenu.new()
	add_child(menu)
	menu.add_item("Show window", 1)
	menu.add_item("Quit", 2) # Avoid brittle accelerators across platforms
	si.menu = menu.get_path()
	menu.id_pressed.connect(_on_menu_item_pressed)

func _on_menu_item_pressed(id: int) -> void:
	match id:
		1:
			get_tree().get_root().show()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2:
			get_tree().quit()

func _on_si_pressed(key: MouseButton, _position: Vector2) -> void:
	if key == MOUSE_BUTTON_LEFT:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		get_tree().get_root().show()
