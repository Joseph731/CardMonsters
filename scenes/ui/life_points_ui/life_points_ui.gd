extends Panel

@onready var minus_500_button: Button = $VBoxContainer/HBoxContainer/Minus500Button
@onready var minus_100_button: Button = $VBoxContainer/HBoxContainer/Minus100Button
@onready var minus_50_button: Button = $VBoxContainer/HBoxContainer/Minus50Button
@onready var plus_50_button: Button = $VBoxContainer/HBoxContainer/Plus50Button
@onready var plus_100_button: Button = $VBoxContainer/HBoxContainer/Plus100Button
@onready var plus_500_button: Button = $VBoxContainer/HBoxContainer/Plus500Button
@onready var label: Label = $VBoxContainer/Label

var life_points: int = 8000

func _ready() -> void:
	minus_500_button.pressed.connect(_on_minus_500_button_pressed)
	minus_100_button.pressed.connect(_on_minus_100_button_pressed)
	minus_50_button.pressed.connect(_on_minus_50_button_pressed)
	plus_50_button.pressed.connect(_on_plus_50_button_pressed)
	plus_100_button.pressed.connect(_on_plus_100_button_pressed)
	plus_500_button.pressed.connect(_on_plus_500_button_pressed)

@rpc("any_peer", "call_local", "reliable")
func UpdateLifePoints(new_life_points: int):
	if new_life_points < 0:
		new_life_points = 0
	life_points = new_life_points
	label.text = str(life_points)

func _on_minus_500_button_pressed() -> void:
	life_points -= 500
	UpdateLifePoints.rpc(life_points)
func _on_minus_100_button_pressed() -> void:
	life_points -= 100
	UpdateLifePoints.rpc(life_points)
func _on_minus_50_button_pressed() -> void:
	life_points -= 50
	UpdateLifePoints.rpc(life_points)
func _on_plus_50_button_pressed() -> void:
	life_points += 50
	UpdateLifePoints.rpc(life_points)
func _on_plus_100_button_pressed() -> void:
	life_points += 100
	UpdateLifePoints.rpc(life_points)
func _on_plus_500_button_pressed() -> void:
	life_points += 500
	UpdateLifePoints.rpc(life_points)
