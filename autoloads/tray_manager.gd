## needs a custom gdextension (for linux support atleast) or can use the web build in electron for it's tray hiding feature...)
extends Node

func _ready() -> void:
	var si : StatusIndicator = StatusIndicator.new()
	si.icon = load("res://fastlane/metadata/android/en-US/images/icon.png")
	si.tooltip = "Pomodorot"
	si.pressed.connect(_on_si_pressed)
	add_child(si)
	
	var menu: PopupMenu = PopupMenu.new()
	add_child(menu)
	menu.add_item("Show window", 1)
	menu.add_item("Quit", 2, KEY_ALT | KEY_F4)
	si.menu = menu.get_path()
	menu.id_pressed.connect(_on_menu_item_pressed)

func _on_menu_item_pressed(id: int) -> void:
	match id:
		1:
			get_tree().get_root().show()
		2:
			get_tree().quit()
			

func _on_si_pressed(key: MouseButton, _position: Vector2) -> void:
	if key == MOUSE_BUTTON_LEFT:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		get_window().show()
