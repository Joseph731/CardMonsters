extends CanvasLayer
class_name ScrollHandMenu

signal move_pressed(card_index: int)
signal show_opponent_pressed(card_texture_resource_path: String)
signal shuffle_pressed
signal add_card_to_hand(card_index: int)

const CARD_MENU = preload("uid://danfrumkq1h60")
const INSPECT_MENU = preload("uid://de5c2kpywyosa")
const ADD_TO_HAND_MENU = preload("uid://gt27a8rnr37n")

@onready var h_box_container: HBoxContainer = $Control/ScrollContainer/HBoxContainer
@onready var shuffle_button: Button = $Control/ShuffleButton

var cards: Array[Card]

var _is_for_my_own_hand: bool = true
var is_for_my_own_hand: bool:
	get:
		return _is_for_my_own_hand
	set(value):
		_is_for_my_own_hand = value
		if !value:
			shuffle_button.queue_free()

func _ready() -> void:
	shuffle_button.pressed.connect(_on_shuffle_pressed)

func add_card(card: Card) -> void:
	var control_node = Control.new()
	control_node.custom_minimum_size = Vector2(172, 250)
	control_node.mouse_filter = Control.MOUSE_FILTER_PASS
	h_box_container.add_child(control_node)
	control_node.add_child(card)
	card.position = control_node.custom_minimum_size/2
	card.to_hand_size()
	card.to_face_up()
	card.control.mouse_filter = Control.MOUSE_FILTER_PASS
	cards.append(card)
	card.control.gui_input.connect(_on_control_gui_input.bind(card))

func _on_control_gui_input(event: InputEvent, card: Card) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			
			if is_for_my_own_hand:
				var card_menu: CardMenu = CARD_MENU.instantiate()
				get_parent().add_child(card_menu)
				card_menu.center_container.position = card.global_position
				card_menu.move_pressed.connect(_on_move_pressed.bind(card))
				card_menu.inspect_pressed.connect(_on_inspect_pressed.bind(card))
				card_menu.show_opponent_pressed.connect(_on_show_opponent_pressed.bind(card.face_up_sprite.texture.resource_path))
			
			else:
				var add_to_hand_menu: AddToHandMenu = ADD_TO_HAND_MENU.instantiate()
				get_parent().add_child(add_to_hand_menu)
				add_to_hand_menu.center_container.position = card.global_position
				add_to_hand_menu.add_to_hand_pressed.connect(_on_add_to_hand_pressed.bind(card))
				add_to_hand_menu.inspect_pressed.connect(_on_inspect_pressed.bind(card))
				add_to_hand_menu.show_opponent_pressed.connect(_on_show_opponent_pressed.bind(card.face_up_sprite.texture.resource_path))
		
func _on_move_pressed(card: Card) -> void:
	move_pressed.emit(cards.find(card))
	queue_free()

func _on_inspect_pressed(card: Card) -> void:
	var inspect_menu: InspectMenu = INSPECT_MENU.instantiate()
	get_parent().add_child(inspect_menu)
	inspect_menu.sprite_2d.texture = card.face_up_sprite.texture

func _on_show_opponent_pressed(card_texture_resource_path: String):
	show_opponent_pressed.emit(card_texture_resource_path)

func _on_shuffle_pressed():
	shuffle_pressed.emit()
	queue_free()

func _on_add_to_hand_pressed(card: Card) -> void:
	add_card_to_hand.emit(cards.find(card))
	cards.erase(card)
	card.get_parent().queue_free()
	if cards.size() <= 0:
		queue_free()
