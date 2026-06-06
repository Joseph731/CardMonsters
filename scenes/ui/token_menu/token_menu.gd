extends ButtonMenu
class_name TokenMenu

signal create_token_pressed

@onready var create_token_button: Button = $CenterContainer/VBoxContainer/CreateTokenButton

func _ready() -> void:
	super._ready()
	create_token_button.pressed.connect(_on_create_token_pressed)

func _on_create_token_pressed() -> void:
	create_token_pressed.emit()
	queue_free()
