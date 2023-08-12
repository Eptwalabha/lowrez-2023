class_name GameOverOverlay
extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationTree

func overlay_show() -> void:
	visible = true
	anim.play("show")

func ovelay_hide() -> void:
	visible = false
	anim.stop()

func _blink() -> void:
	anim.play("blink")
