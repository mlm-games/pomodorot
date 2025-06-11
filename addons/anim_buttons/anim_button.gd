@tool
class_name AnimButton extends Button

static var click_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
static var hover_sound_player: AudioStreamPlayer = AudioStreamPlayer.new()

@export var hover_audio: AudioStream:
	get: return hover_sound_player.stream if hover_sound_player else null
	set(val): hover_sound_player.stream  = val

@export var click_audio: AudioStream:
	get: return click_stream_player.stream if click_stream_player else null
	set(val): click_stream_player.stream  = val

var tween: Tween

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)
	
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	pivot_offset = size/2
	
	hover_sound_player.bus = "Sfx"
	click_stream_player.bus = "Sfx"
	#get_tree().get_root().add_child.call_deferred(click_stream_player)
	

func _on_mouse_entered() -> void:
	pivot_offset = size/2
	reset_tween()
	tween.tween_property(self, "scale", Vector2(1.075, 1.075), 0.15).set_trans(Tween.TRANS_CUBIC)
	if hover_audio: hover_sound_player.play()

func _on_mouse_exited() -> void:
	pivot_offset = size/2
	reset_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_CUBIC)

func _on_button_down() -> void:
	pivot_offset = size/2
	reset_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_CUBIC)

func _on_button_up() -> void:
	pivot_offset = size/2
	reset_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)


func _on_pressed() -> void:
	if click_audio: 
		click_stream_player.play()


#FIXME: Doesnt work due to the timers not being syncronised properly, hence looking bad.
	#await get_tree().create_timer(0.15).timeout
	#_on_mouse_entered()

#func _exit_tree() -> void:
	#await click_stream_player.finished
	#click_stream_player.volume_db = -1000
	#if click_stream_player: click_stream_player.queue_free()

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
