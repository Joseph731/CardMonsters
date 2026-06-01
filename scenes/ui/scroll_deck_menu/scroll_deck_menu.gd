extends CanvasLayer
class_name ScrollDeckMenu

signal add_card_to_hand(card_index: int)
signal show_opponent_pressed(card_texture_resource_path: String)

const ADD_TO_HAND_MENU = preload("uid://gt27a8rnr37n")
const INSPECT_MENU = preload("uid://de5c2kpywyosa")

@onready var v_box_container: VBoxContainer = $Control/ScrollContainer/VBoxContainer

var cards: Array[Card]

func add_card(card: Card) -> void:
	var control_node = Control.new()
	control_node.custom_minimum_size = Vector2(172, 250)
	control_node.mouse_filter = Control.MOUSE_FILTER_PASS
	v_box_container.add_child(control_node)
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
			var add_to_hand_menu: AddToHandMenu = ADD_TO_HAND_MENU.instantiate()
			get_parent().add_child(add_to_hand_menu)
			add_to_hand_menu.center_container.position = card.global_position
			add_to_hand_menu.add_to_hand_pressed.connect(_on_add_to_hand_pressed.bind(card))
			add_to_hand_menu.inspect_pressed.connect(_on_inspect_pressed.bind(card))
			add_to_hand_menu.show_opponent_pressed.connect(_on_show_opponent_pressed.bind(card.face_up_sprite.texture.resource_path))
		
func _on_add_to_hand_pressed(card: Card) -> void:
	add_card_to_hand.emit(cards.find(card))
	cards.erase(card)
	card.get_parent().queue_free()
	if cards.size() <= 0:
		queue_free()

func _on_inspect_pressed(card: Card) -> void:
	var inspect_menu: InspectMenu = INSPECT_MENU.instantiate()
	get_parent().add_child(inspect_menu)
	inspect_menu.sprite_2d.texture = card.face_up_sprite.texture

func _on_show_opponent_pressed(card_texture_resource_path: String):
	show_opponent_pressed.emit(card_texture_resource_path)

func reverse_children() -> void:
	var children_snapshot = v_box_container.get_children()
	children_snapshot.reverse()
	for i in range(children_snapshot.size()):
		v_box_container.move_child(children_snapshot[i], i)
