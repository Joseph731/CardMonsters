extends Control
class_name AllowMenu

signal yes_pressed()
signal no_pressed()

@onready var yes_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/YesButton
@onready var no_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/NoButton

func _ready() -> void:
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)

func _on_yes_pressed() -> void:
	yes_pressed.emit()
	queue_free()

func _on_no_pressed() -> void:
	no_pressed.emit()
	queue_free()
