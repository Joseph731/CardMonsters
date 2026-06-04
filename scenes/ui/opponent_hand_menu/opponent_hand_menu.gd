extends ButtonMenu
class_name OpponentHandMenu

signal see_hand_pressed

@onready var see_hand_button: Button = $CenterContainer/VBoxContainer/SeeHandButton

func _ready() -> void:
	super._ready()
	see_hand_button.pressed.connect(_on_see_hand_pressed)

func _on_see_hand_pressed() -> void:
	see_hand_pressed.emit()
	queue_free()
