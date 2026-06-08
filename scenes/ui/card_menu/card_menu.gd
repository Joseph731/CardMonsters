extends ButtonMenu
class_name CardMenu

signal attack_pressed
signal move_pressed
signal inspect_pressed
signal show_opponent_pressed

@onready var attack_button: Button = $CenterContainer/VBoxContainer/AttackButton
@onready var move_button: Button = %MoveButton
@onready var show_opponent_button: Button = %ShowOpponentButton
@onready var inspect_button: Button = %InspectButton

func _ready() -> void:
	super._ready()
	attack_button.pressed.connect(_on_attack_button_pressed)
	move_button.pressed.connect(_on_move_button_pressed)
	inspect_button.pressed.connect(_on_inspect_button_pressed)
	show_opponent_button.pressed.connect(_on_show_opponent_button_pressed)

func _on_attack_button_pressed() -> void:
	attack_pressed.emit()
	queue_free()

func _on_move_button_pressed() -> void:
	move_pressed.emit()
	queue_free()

func _on_inspect_button_pressed() -> void:
	inspect_pressed.emit()
	queue_free()

func _on_show_opponent_button_pressed() -> void:
	show_opponent_pressed.emit()
	queue_free()
