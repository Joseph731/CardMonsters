extends Node2D
class_name CardContainer

signal clicked(card_container: CardContainer)

@export var field_zone_sized_cards: bool
@export var is_field_zone: bool
@export var enforce_occupied: bool

@onready var area_2d: Area2D = $Area2D

var cards: Array[Card]

func _ready() -> void:
	area_2d.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			_on_card_container_clicked()

func _on_card_container_clicked() -> void:
	clicked.emit(self)


func add_card(card: Card) -> void:
	add_child(card)
	cards.append(card)
	card.card_container_im_inside = self
	if field_zone_sized_cards:
		card.to_field_size()
	card.position = Vector2(0,0)

func remove_card(card: Card) -> void:
	remove_child(card)
	cards.erase(card)
	card.card_container_im_inside = null
