extends ButtonMenu
class_name CardMenu

signal move_pressed
signal inspect_pressed

@onready var move_button: Button = %MoveButton
@onready var inspect_button: Button = %InspectButton

func _ready() -> void:
	super._ready()
	move_button.pressed.connect(_on_move_button_pressed)
	inspect_button.pressed.connect(_on_inspect_button_pressed)

func _on_move_button_pressed() -> void:
	move_pressed.emit()
	queue_free()

func _on_inspect_button_pressed() -> void:
	inspect_pressed.emit()
	queue_free()
