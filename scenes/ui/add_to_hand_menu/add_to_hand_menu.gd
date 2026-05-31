extends ButtonMenu
class_name AddToHandMenu

signal add_to_hand_pressed
signal inspect_pressed

@onready var add_to_hand_button: Button = %AddToHandButton
@onready var inspect_button: Button = %InspectButton

func _ready() -> void:
	super._ready()
	add_to_hand_button.pressed.connect(_on_add_to_hand_pressed)
	inspect_button.pressed.connect(_on_inspect_pressed)

func _on_add_to_hand_pressed() -> void:
	add_to_hand_pressed.emit()
	queue_free()

func _on_inspect_pressed() -> void:
	inspect_pressed.emit()
	queue_free()
