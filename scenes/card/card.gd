extends Node2D
class_name Card

signal clicked(card: Card)

enum Card_Position { FACE_UP_ATTACK, FACE_UP_DEFENSE, FACE_DOWN_ATTACK, FACE_DOWN_DEFENSE}

const HAND_SIZE: Vector2 = Vector2(172, 250)
const FIELD_SIZE: Vector2 = Vector2(138, 200)
const FULL_SIZE: Vector2 = Vector2(685, 1000)

@onready var face_down_sprite: Sprite2D = $FaceDown
@onready var face_up_sprite: Sprite2D = $FaceUp
@onready var glow: Sprite2D = $Glow
@onready var control: Control = $Control

var card_container_im_inside: CardContainer

var _card_position: Card_Position
var card_position: Card_Position:
	get:
		return _card_position
	set(value):
		_card_position = value
		match value:
			Card.Card_Position.FACE_UP_ATTACK:
				to_face_up()
				to_attack_position()
			Card.Card_Position.FACE_UP_DEFENSE:
				to_face_up()
				to_defense_position()
			Card.Card_Position.FACE_DOWN_ATTACK:
				to_face_down()
				to_attack_position()
			Card.Card_Position.FACE_DOWN_DEFENSE:
				to_face_down()
				to_defense_position()

func _ready() -> void:
	control.gui_input.connect(_on_control_gui_input)

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			clicked.emit(self)

func to_field_size() -> void:
	face_down_sprite.scale = Vector2(1, 1) * FIELD_SIZE / FULL_SIZE
	face_up_sprite.scale = Vector2(1, 1) * FIELD_SIZE / FULL_SIZE
	glow.scale = Vector2(1, 1) * FIELD_SIZE / FULL_SIZE
	control.size = FIELD_SIZE
	control.position = -FIELD_SIZE/2
	control.pivot_offset = FIELD_SIZE/2

func to_hand_size() -> void:
	face_down_sprite.scale = Vector2(1, 1) * HAND_SIZE / FULL_SIZE
	face_up_sprite.scale = Vector2(1, 1) * HAND_SIZE / FULL_SIZE
	glow.scale = Vector2(1, 1) * HAND_SIZE / FULL_SIZE
	control.size = HAND_SIZE
	control.position = -HAND_SIZE/2
	control.pivot_offset = HAND_SIZE/2

func to_face_up() -> void:
	face_down_sprite.visible = false
	face_up_sprite.visible = true

func to_face_down() -> void:
	face_down_sprite.visible = true
	face_up_sprite.visible = false

func to_defense_position() -> void:
	face_down_sprite.rotation_degrees = 90
	face_up_sprite.rotation_degrees = 90
	glow.rotation_degrees = 90
	control.rotation_degrees = 90

func to_attack_position() -> void:
	face_down_sprite.rotation_degrees = 0
	face_up_sprite.rotation_degrees = 0
	glow.rotation_degrees = 0
	control.rotation_degrees = 0
