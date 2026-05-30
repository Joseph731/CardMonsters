extends ButtonMenu
class_name CardMenu

signal move_pressed

@onready var move_button: Button = %MoveButton

func _ready() -> void:
	super._ready()
	move_button.pressed.connect(_on_move_button_pressed)

func _on_move_button_pressed() -> void:
	move_pressed.emit()
	queue_free()
