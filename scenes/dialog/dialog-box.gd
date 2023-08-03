class_name DialogBox
extends CanvasLayer

@onready var typer_sound: AudioStreamPlayer = $TyperSound
@onready var dialog: RichTextLabel = $Margin/Dialog
@onready var timer: Timer = $Timer

@export var text : String = ""
@export var typer_speed : TYPER_SPEED = TYPER_SPEED.NORMAL

var typer_delay : float = 0
const TYPER_SOUND_DELAY : int = 2

enum TYPER_SPEED {
	SLOW,
	NORMAL,
	FAST,
	INSTANT
}

func _ready() -> void:
	set_text(text)
	update_visibility()

func set_text(new_text: String) -> void:
	text = new_text
	dialog.text = new_text
	if typer_speed == TYPER_SPEED.INSTANT:
		dialog.visible_characters = -1
	else:
		dialog.visible_characters = 0
	update_visibility()

func show_letter() -> void:
	dialog.visible_characters += 1
	if dialog.visible_characters % TYPER_SOUND_DELAY == 0:
		typer_sound.play()
	if dialog.visible_ratio < 1.0:
		timer.start()

func update_visibility() -> void:
	typer_delay = .05
	if typer_speed == TYPER_SPEED.INSTANT:
		dialog.visible_characters = -1
		timer.stop()
	else:
		match typer_speed:
			TYPER_SPEED.SLOW: typer_delay = .08
			TYPER_SPEED.NORMAL: typer_delay = .04
			TYPER_SPEED.FAST: typer_delay = .02
		timer.wait_time = typer_delay
		timer.start()

func _on_timer_timeout() -> void:
	show_letter()
