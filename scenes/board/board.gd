extends Node

const CARD_MENU = preload("uid://danfrumkq1h60")
const CARD = preload("uid://cguukq18jkrx2")
const DECK_MENU = preload("uid://s7kkqewb2ppt")
const CARD_POSITION_MENU = preload("uid://b8qbcu077yrq7")
const SCROLL_DECK_MENU = preload("uid://cks00hlm6vnr8")
const TO_TOP_OR_BOTTOM_MENU = preload("uid://b07f035bw35ox")
const INSPECT_MENU = preload("uid://de5c2kpywyosa")

@onready var reflection_point: Marker2D = $ReflectionPoint
@onready var hand1: Hand = $Hand1
@onready var hand2: Hand = $Hand2
@onready var deck1: CardContainer = $Deck1
@onready var deck2: CardContainer= $Deck2
@onready var graveyard1: Node2D = $Graveyard1
@onready var graveyard2: Node2D = $Graveyard2
@onready var banished1: Node2D = $Banished1
@onready var banished2: Node2D = $Banished2
@onready var extra_deck1: Node2D = $ExtraDeck1
@onready var extra_deck2: Node2D = $ExtraDeck2
@onready var field_zone1: CardContainer = $FieldZone1
@onready var field_zone2: CardContainer = $FieldZone2
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
	
	var card_containers: Array[CardContainer]
	card_containers.assign(spell_zone1.get_children())
	card_containers.append_array(spell_zone2.get_children())
	card_containers.append_array(monster_zone1.get_children())
	card_containers.append_array(monster_zone2.get_children())
	card_containers.append(field_zone1)
	card_containers.append(field_zone2)
	card_containers.append(hand1)
	card_containers.append(hand2)
	card_containers.append(deck1)
	card_containers.append(deck2)
	card_containers.append(graveyard1)
	card_containers.append(graveyard2)
	card_containers.append(banished1)
	card_containers.append(banished2)
	card_containers.append(extra_deck1)
	card_containers.append(extra_deck2)
	
	for card_container in card_containers:
		if card_container is Deck:
			card_container.clicked.connect(_on_deck_clicked)
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
		if i % 2 == 0:
			card.face_up_sprite.texture = load("res://scenes/card/happy_reborn.png")
		card = CARD.instantiate()
		card.clicked.connect(_on_card_clicked)
		deck2.add_card(card)
		if i % 2 == 0:
			card.face_up_sprite.texture = load("res://scenes/card/happy_reborn.png")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drop_carried_card"):
		if menu_container.get_child_count() != 0:
			menu_container.get_children()[-1].queue_free()
		carried_card = null

@rpc("any_peer", "call_local", "reliable")
func move_card_to_card_container(card_path: String, target_card_container_path: String) -> void:
	var card: Card = get_node(card_path)
	var target_card_container: CardContainer = get_node(target_card_container_path)
	move_card_from_container_to_container(card, 
		card.card_container_im_inside, target_card_container)

func move_card_from_container_to_container(card: Card,
	container1: CardContainer, container2: CardContainer) -> void:
	container1.remove_card(card)
	container2.add_card(card)

func _on_card_clicked(card: Card) -> void:
	if carried_card != null:
		return
	var card_menu: CardMenu = CARD_MENU.instantiate()
	card_menu.move_pressed.connect(_on_move_pressed.bind(card))
	card_menu.inspect_pressed.connect(_on_inspect_pressed.bind(card.face_up_sprite.texture))
	menu_container.add_child(card_menu)
	card_menu.center_container.global_position = card.global_position

func _on_move_pressed(card: Card) -> void:
	carried_card = card

func _on_inspect_pressed(card_texture: Texture2D):
	var inspect_menu: InspectMenu = INSPECT_MENU.instantiate()
	menu_container.add_child(inspect_menu)
	inspect_menu.sprite_2d.texture = card_texture

func _on_card_container_clicked(card_container: CardContainer) -> void:
	if carried_card == null:
		return
	get_viewport().set_input_as_handled()
	
	if (card_container.enforce_occupied && card_container.cards.size() > 0
			&& card_container.cards[0] != carried_card):
		return
	
	var card_container_parent = card_container.get_parent()
	if (card_container_parent == spell_zone1 || card_container_parent == spell_zone2
		|| card_container_parent == monster_zone1 || card_container_parent == monster_zone2):
			var card_position_menu: CardPositionMenu = CARD_POSITION_MENU.instantiate()
			card_position_menu.position_selected.connect(_on_position_selected.bind(card_container.get_path()))
			menu_container.add_child(card_position_menu)
			if card_container_parent == spell_zone1 || card_container_parent == spell_zone2:
				card_position_menu.to_spell_zone_position_menu()
			elif card_container_parent == monster_zone1 || card_container_parent == monster_zone2:
				card_position_menu.to_monster_zone_position_menu()
			card_position_menu.center_container.global_position = card_container.global_position
	elif card_container == deck1 || card_container == deck2:
		var to_top_or_bottom_menu: ToTopOrBottomMenu = TO_TOP_OR_BOTTOM_MENU.instantiate()
		to_top_or_bottom_menu.choice_selected.connect(_on_top_or_bottom_choice_selected.bind(card_container.get_path()))
		menu_container.add_child(to_top_or_bottom_menu)
		to_top_or_bottom_menu.center_container.global_position = card_container.global_position
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

func _on_top_or_bottom_choice_selected(choice, card_container_path: String) -> void:
	if choice != null:
		move_card_to_card_container.rpc(carried_card.get_path(), card_container_path)
		if choice == ToTopOrBottomMenu.Choice.Bottom:
			get_node(card_container_path).move_card_to_bottom.rpc(carried_card.get_path())
	carried_card = null

func _on_deck_clicked(deck: Deck) -> void:
	if carried_card != null:
		return
	if deck.cards.size() == 0:
		return
	
	var deck_menu: DeckMenu = DECK_MENU.instantiate()
	deck_menu.draw_pressed.connect(_on_draw_pressed.bind(deck))
	deck_menu.search_pressed.connect(_on_search_pressed.bind(deck))
	deck_menu.shuffle_pressed.connect(_on_shuffle_pressed.bind(deck))
	menu_container.add_child(deck_menu)
	if deck != deck1 && deck != deck2:
		deck_menu.to_no_draw_deck_menu()
	deck_menu.center_container.global_position = deck.global_position

func _on_draw_pressed(deck: Deck) -> void:
	if deck.is_being_searched:
		return
	var target_hand: Hand
	if is_multiplayer_authority():
		target_hand = hand1
	else:
		target_hand = hand2
	move_card_to_card_container.rpc(deck.cards.back().get_path(), target_hand.get_path())

func _on_search_pressed(deck: Deck) -> void:
	if deck.is_being_searched:
		return
	for menu in menu_container.get_children():
		if menu is ScrollDeckMenu:
			menu.queue_free()
	deck.is_being_searched = true
	var scroll_deck_menu: ScrollDeckMenu = SCROLL_DECK_MENU.instantiate()
	scroll_deck_menu.add_card_to_hand.connect(_on_add_card_to_hand.bind(deck))
	scroll_deck_menu.tree_exited.connect(_on_scroll_deck_menu_tree_exited.bind(deck))
	menu_container.add_child(scroll_deck_menu)
	for card in deck.cards:
		scroll_deck_menu.add_card(card.duplicate())
	scroll_deck_menu.reverse_children()

func _on_add_card_to_hand(card_index: int, deck: CardContainer) -> void:
	var target_hand: CardContainer
	if is_multiplayer_authority():
		target_hand = hand1
	else:
		target_hand = hand2
	move_card_to_card_container.rpc(deck.cards[card_index].get_path(), target_hand.get_path())

func _on_scroll_deck_menu_tree_exited(deck: Deck) -> void:
	deck.is_being_searched = false

func _on_shuffle_pressed(deck: Deck) -> void:
	deck.cards.shuffle()
	var card_data_array: Array
	for card in deck.cards:
		card_data_array.append({"texture": card.face_up_sprite.texture.resource_path})
	synchronize_decks.rpc(deck.get_path(), card_data_array)

@rpc("any_peer", "call_local", "reliable") #call_local so the card references are the same for both peers
func synchronize_decks(deck_path: String, card_data_array: Array) -> void:
	var deck: Deck = get_node(deck_path)
	for card in deck.cards_node.get_children():
		deck.remove_card(card)
	for card_data in card_data_array:
		var card: Card = CARD.instantiate()
		deck.add_card(card)
		card.clicked.connect(_on_card_clicked)
		card.face_up_sprite.texture = load(card_data["texture"])
