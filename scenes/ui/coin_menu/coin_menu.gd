extends ButtonMenu
class_name CoinMenu

signal flip_pressed

@onready var flip_button: Button = $CenterContainer/VBoxContainer/FlipButton

func _ready() -> void:
	super._ready()
	flip_button.pressed.connect(_on_flip_pressed)

func _on_flip_pressed():
	flip_pressed.emit()
	queue_free()
