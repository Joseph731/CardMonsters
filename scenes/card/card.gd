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
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

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
	area_2d.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			clicked.emit(self)

func to_field_size() -> void:
	face_down_sprite.scale = Vector2(1, 1) * FIELD_SIZE / FULL_SIZE
	face_up_sprite.scale = Vector2(1, 1) * FIELD_SIZE / FULL_SIZE
	glow.scale = Vector2(1, 1) * FIELD_SIZE / FULL_SIZE
	collision_shape_2d.shape.size = FIELD_SIZE

func to_hand_size() -> void:
	face_down_sprite.scale = Vector2(1, 1) * HAND_SIZE / FULL_SIZE
	face_up_sprite.scale = Vector2(1, 1) * HAND_SIZE / FULL_SIZE
	glow.scale = Vector2(1, 1) * HAND_SIZE / FULL_SIZE
	collision_shape_2d.shape.size = HAND_SIZE

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
	collision_shape_2d.rotation_degrees = 90

func to_attack_position() -> void:
	face_down_sprite.rotation_degrees = 0
	face_up_sprite.rotation_degrees = 0
	glow.rotation_degrees = 0
	collision_shape_2d.rotation_degrees = 0
