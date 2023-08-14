class_name GameOverOverlay
extends CanvasLayer

signal restart_requested

@onready var anim: AnimationPlayer = $AnimationTree

var can_click : bool = true

func overlay_show() -> void:
	can_click = false
	anim.play("show")

func overlay_hide() -> void:
	visible = false
	can_click = false
	$Control/VBoxContainer/Banner.modulate.a = 0.0
	$Control.modulate.a = 0.0
	$Control/VBoxContainer/PlayAgain.visible = false
	anim.stop()

func _unhandled_input(event: InputEvent) -> void:
	if can_click and event.is_action_pressed("ui_accept"):
		emit_signal("restart_requested")

func _blink() -> void:
	can_click = true
	anim.play("blink")
