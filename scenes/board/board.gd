extends Node

const CARD_MENU = preload("uid://danfrumkq1h60")
const CARD = preload("uid://cguukq18jkrx2") #TEMP FOR DEVELOPMENT
const DECK_MENU = preload("uid://s7kkqewb2ppt")
const CARD_POSITION_MENU = preload("uid://b8qbcu077yrq7")

@onready var reflection_point: Marker2D = $ReflectionPoint
@onready var hand1: Hand = $Hand1
@onready var hand2: Hand = $Hand2
@onready var deck1: CardContainer = $Deck1
@onready var deck2: CardContainer= $Deck2
@onready var spell_zone1: Node = $SpellZone1
@onready var spell_zone2: Node = $SpellZone2
@onready var monster_zone1: Node = $MonsterZone1
@onready var monster_zone2: Node = $MonsterZone2
@onready var menu_container: Node = $MenuContainer

var _carried_card: Card
var carried_card: Card:
	get:
		return _carried_card
	set(value):
		if value == null:
			if _carried_card != null:
				_carried_card.glow.visible = false
		else:
			value.glow.visible = true
		_carried_card = value

func _ready() -> void:
	deck1.clicked.connect(_on_deck_clicked)
	deck2.clicked.connect(_on_deck_clicked)
	
	var card_containers: Array[CardContainer]
	card_containers.assign(spell_zone1.get_children())
	card_containers.append_array(spell_zone2.get_children())
	card_containers.append_array(monster_zone1.get_children())
	card_containers.append_array(monster_zone2.get_children())
	card_containers.append(hand1)
	card_containers.append(hand2)
	card_containers.append(deck1)
	card_containers.append(deck2)
	for card_container in card_containers:
		card_container.clicked.connect(_on_card_container_clicked)
		if !is_multiplayer_authority() && card_container is not Hand:
			card_container.global_position.x = reflection_point.position.x * 2 - card_container.global_position.x
			card_container.global_position.y = reflection_point.position.y * 2 - card_container.global_position.y
		if card_container.global_position.y < reflection_point.global_position.y:
			card_container.rotate(PI)
	
	if is_multiplayer_authority():
		hand2.area_2d.input_pickable = false
	else:
		hand1.area_2d.input_pickable = false
	
	for i in range(10):
		var card: Card = CARD.instantiate()
		card.clicked.connect(_on_card_clicked)
		deck1.add_card(card)
		card.collision_shape_2d.shape = card.collision_shape_2d.shape.duplicate(true)
		card = CARD.instantiate()
		card.clicked.connect(_on_card_clicked)
		deck2.add_card(card)
		card.collision_shape_2d.shape = card.collision_shape_2d.shape.duplicate(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drop_carried_card"):
		if menu_container.get_child_count() != 0:
			menu_container.get_children()[-1].queue_free()
		carried_card = null

func move_card_from_container_to_container(card: Card,
	container1: CardContainer, container2: CardContainer) -> void:
	container1.remove_card(card)
	container2.add_card(card)

func _on_card_clicked(card: Card) -> void:
	if carried_card != null:
		return
	
	var card_menu: CardMenu = CARD_MENU.instantiate()
	card_menu.move_pressed.connect(_on_move_pressed.bind(card))
	menu_container.add_child(card_menu)
	card_menu.center_container.global_position = card.global_position

func _on_move_pressed(card: Card) -> void:
	carried_card = card

func _on_card_container_clicked(card_container: CardContainer) -> void:
	if carried_card == null:
		return
	
	get_viewport().set_input_as_handled()
	
	if (card_container.enforce_occupied && card_container.cards.size() > 0
			&& card_container.cards[0] != carried_card):
		return
	
	if card_container.is_field_zone:
		var card_position_menu: CardPositionMenu = CARD_POSITION_MENU.instantiate()
		card_position_menu.position_selected.connect(_on_position_selected.bind(card_container.get_path()))
		menu_container.add_child(card_position_menu)
		card_position_menu.center_container.global_position = card_container.global_position
	else:
		move_card_to_card_container.rpc(carried_card.get_path(), card_container.get_path())
		carried_card = null

func _on_position_selected(selected_card_position, card_container_path: String) -> void:
	if selected_card_position != null:
		set_card_position.rpc(carried_card.get_path(), selected_card_position)
		move_card_to_card_container.rpc(carried_card.get_path(), card_container_path)
	carried_card = null

@rpc("any_peer", "call_local", "reliable")
func set_card_position(card_path: String, target_card_position: Card.Card_Position) -> void:
	var card: Card = get_node(card_path)
	card.card_position = target_card_position

@rpc("any_peer", "call_local", "reliable")
func move_card_to_card_container(card_path: String, target_card_container_path: String) -> void:
	var card: Card = get_node(card_path)
	var target_card_container: CardContainer = get_node(target_card_container_path)
	move_card_from_container_to_container(card, 
		card.card_container_im_inside, target_card_container)
	

func _on_deck_clicked(deck: CardContainer) -> void:
	if carried_card != null:
		return
	if deck.cards.size() == 0:
		return
	
	var deck_menu: DeckMenu = DECK_MENU.instantiate()
	deck_menu.draw_pressed.connect(_on_draw_pressed.bind(deck))
	menu_container.add_child(deck_menu)
	deck_menu.center_container.global_position = deck.global_position

func _on_draw_pressed(deck: CardContainer) -> void:
	var target_hand: Hand
	if is_multiplayer_authority():
		target_hand = hand1
	else:
		target_hand = hand2
	move_card_to_card_container.rpc(deck.cards[-1].get_path(), target_hand.get_path())
