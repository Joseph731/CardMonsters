extends ButtonMenu
class_name AddToHandMenu

signal add_to_hand_pressed

@onready var add_to_hand_button: Button = %AddToHandButton

func _ready() -> void:
	super._ready()
	add_to_hand_button.pressed.connect(_on_add_to_hand_pressed)

func _on_add_to_hand_pressed() -> void:
	add_to_hand_pressed.emit()
	queue_free()
