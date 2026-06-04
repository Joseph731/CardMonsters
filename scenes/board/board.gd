extends Node

const CARD_MENU = preload("uid://danfrumkq1h60")
const CARD = preload("uid://cguukq18jkrx2")
const DECK_MENU = preload("uid://s7kkqewb2ppt")
const CARD_POSITION_MENU = preload("uid://b8qbcu077yrq7")
const SCROLL_DECK_MENU = preload("uid://cks00hlm6vnr8")
const SCROLL_HAND_MENU = preload("uid://cva0yl36t3n8i")
const TO_TOP_OR_BOTTOM_MENU = preload("uid://b07f035bw35ox")
const INSPECT_MENU = preload("uid://de5c2kpywyosa")
const OPPONENT_HAND_MENU = preload("uid://c8s1vht5myn5u")

@onready var reflection_point: Marker2D = $ReflectionPoint
@onready var hand1: Hand = $Hand1
@onready var hand2: Hand = $Hand2
@onready var deck1: Deck = $Deck1
@onready var deck2: Deck = $Deck2
@onready var graveyard1: Deck = $Graveyard1
@onready var graveyard2: Deck = $Graveyard2
@onready var banished1: Deck = $Banished1
@onready var banished2: Deck = $Banished2
@onready var extra_deck1: Deck = $ExtraDeck1
@onready var extra_deck2: Deck = $ExtraDeck2
@onready var field_zone1: CardContainer = $FieldZone1
@onready var field_zone2: CardContainer = $FieldZone2
@onready var spell_zone1: Node = $SpellZone1
@onready var spell_zone2: Node = $SpellZone2
@onready var monster_zone1: Node = $MonsterZone1
@onready var monster_zone2: Node = $MonsterZone2
@onready var opponent_hand_visual: Control = $OpponentHand
@onready var hand_button: Button = $HandButton
@onready var log_text: LogText = $LogCanvasLayer/LogText
@onready var menu_container: CanvasLayer = $MenuContainer

var enemy_zones: Array[CardContainer]
var opponent_deck: Deck
var opponent_extra_deck: Deck
var opponent_hand: Hand

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
	if is_multiplayer_authority():
		opponent_deck = deck2
		opponent_extra_deck = extra_deck2
		opponent_hand = hand2
		
		enemy_zones.assign(spell_zone2.get_children())
		enemy_zones.append_array(monster_zone2.get_children())
		
		hand_button.pressed.connect(_on_hand_button_pressed.bind(hand1))
	else:
		opponent_deck = deck1
		opponent_extra_deck = extra_deck1
		opponent_hand = hand1
		
		enemy_zones.assign(spell_zone1.get_children())
		enemy_zones.append_array(monster_zone1.get_children())
		
		hand_button.pressed.connect(_on_hand_button_pressed.bind(hand2))
	
	opponent_hand.collision_shape_2d.shape = opponent_hand.collision_shape_2d.shape.duplicate()
	opponent_hand.collision_shape_2d.shape.size = opponent_hand_visual.get_custom_minimum_size()
	opponent_hand.global_position = opponent_hand_visual.global_position + opponent_hand.collision_shape_2d.shape.size / 2
	opponent_hand.card_count_changed.connect(opponent_hand_visual.on_hand_card_count_changed)
	
	opponent_deck.center_container.rotation_degrees = 180
	
	opponent_hand.clicked.connect(_on_opponent_hand_clicked)
	
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
		var index_in_container1: int = container1.cards.find(card)
		container1.remove_card(card)
		container2.add_card(card)
		var index_in_container2: int = container2.cards.find(card)
		
		if (container1 is Hand  || container2 is Hand):
			var log_message: String = "Card moved from " + container1.custom_name
			if container1 is Hand:
				log_message += " (position " + str(index_in_container1 + 1) + ")"
			log_message += " to " + container2.custom_name
			if container2 is Hand:
				log_message += " (position " + str(index_in_container2 + 1) + ")"
			log_message += "."
			log_text.add_message(log_message)

func _on_card_clicked(card: Card) -> void:
	if carried_card != null:
		return
	var card_menu: CardMenu = CARD_MENU.instantiate()
	card_menu.move_pressed.connect(_on_move_pressed.bind(card))
	card_menu.inspect_pressed.connect(_on_inspect_pressed.bind(card.face_up_sprite.texture))
	card_menu.show_opponent_pressed.connect(_on_show_opponent_pressed.bind(card.face_up_sprite.texture.resource_path))
	menu_container.add_child(card_menu)
	if card.card_position == Card.Card_Position.FACE_DOWN_DEFENSE || card.card_position == Card.Card_Position.FACE_DOWN_ATTACK:
		for enemy_zone in enemy_zones:
			if card.card_container_im_inside == enemy_zone:
				card_menu.inspect_button.queue_free()
				card_menu.show_opponent_button.queue_free()
	card_menu.center_container.global_position = card.global_position

func _on_move_pressed(card: Card) -> void:
	carried_card = card

func _on_inspect_pressed(card_texture: Texture2D):
	var inspect_menu: InspectMenu = INSPECT_MENU.instantiate()
	menu_container.add_child(inspect_menu)
	inspect_menu.sprite_2d.texture = card_texture

@rpc("any_peer", "call_remote", "reliable")
func _on_show_opponent_pressed(card_texture_resource_path: String):
	if multiplayer.get_remote_sender_id() == 0:
		_on_show_opponent_pressed.rpc(card_texture_resource_path)
		return
	var inspect_menu: InspectMenu = INSPECT_MENU.instantiate()
	menu_container.add_child(inspect_menu)
	inspect_menu.sprite_2d.texture = load(card_texture_resource_path)

func _on_card_container_clicked(card_container: CardContainer) -> void:
	if carried_card == null:
		return
	get_viewport().set_input_as_handled()
	
	if (card_container.enforce_occupied && card_container.cards.size() > 0
			&& card_container.cards[0] != carried_card):
		return
	
	if card_container is Deck:
		if card_container.is_being_searched == true:
			log_text.add_message("Can't move cards to a deck that is currently being searched.")
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

func _on_top_or_bottom_choice_selected(choice, deck_path: String) -> void:
	if choice != null:
		move_card_to_card_container.rpc(carried_card.get_path(), deck_path)
		var deck: Deck = get_node(deck_path)
		if choice == ToTopOrBottomMenu.Choice.Bottom:
			deck.move_card_to_bottom.rpc(carried_card.get_path())
			log_text.add_message.rpc("Card was moved to the bottom of " + deck.custom_name + ".")
		else:
			log_text.add_message.rpc("Card was moved to the top of " + deck.custom_name + ".")
	carried_card = null

func _on_deck_clicked(deck: Deck) -> void:
	if carried_card != null:
		return
	if deck.cards.is_empty():
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
	if deck.cards.is_empty():
		return
	if deck.is_being_searched:
		log_text.add_message("Can't draw from deck that is currently being searched.")
		return
	var target_hand: Hand
	if opponent_hand == hand2:
		target_hand = hand1
	else:
		target_hand = hand2
	move_card_to_card_container.rpc(deck.cards.back().get_path(), target_hand.get_path())
	log_text.add_message.rpc("Card was drawn from " + deck.custom_name + ".")

func _on_search_pressed(deck: Deck) -> void:
	if deck.cards.is_empty():
		return
	if deck.is_being_searched:
		log_text.add_message("Can't search a deck that is currently being searched.")
		return
	log_text.add_message.rpc(deck.custom_name + " is being searched.")
	
	var scroll_deck_menu: ScrollDeckMenu = SCROLL_DECK_MENU.instantiate()
	scroll_deck_menu.add_card_to_hand.connect(_on_add_card_to_hand.bind(deck))
	scroll_deck_menu.show_opponent_pressed.connect(_on_show_opponent_pressed)
	scroll_deck_menu.tree_exited.connect(_on_scroll_menu_tree_exited.bind(deck))
	menu_container.add_child(scroll_deck_menu)
	for card in deck.cards:
		scroll_deck_menu.add_card(card.duplicate())
	scroll_deck_menu.reverse_children()
	
	deck.is_being_searched = true

func _on_add_card_to_hand(card_index: int, card_container: CardContainer) -> void:
	var target_hand: CardContainer
	if opponent_hand == hand2:
		target_hand = hand1
	else:
		target_hand = hand2
	move_card_to_card_container.rpc(card_container.cards[card_index].get_path(), target_hand.get_path())
	log_text.add_message.rpc("Card was taken from search of " + card_container.custom_name + ".")

func _on_scroll_menu_tree_exited(card_container: CardContainer) -> void:
	if card_container is not Deck && card_container is not Hand:
		return
	card_container.is_being_searched = false

func _on_shuffle_pressed(card_container: CardContainer) -> void:
	if card_container.cards.is_empty():
		return
	if card_container is Deck:
		if card_container.is_being_searched:
			log_text.add_message("Can't shuffle a deck that is currently being searched.")
			return
	
	card_container.cards.shuffle()
	var card_data_array: Array
	for card in card_container.cards:
		card_data_array.append({"texture": card.face_up_sprite.texture.resource_path,
			"unique_id": str(ResourceUID.create_id())})
	synchronize_card_containers.rpc(card_container.get_path(), card_data_array)
	log_text.add_message.rpc(card_container.custom_name + " was shuffled.")

@rpc("any_peer", "call_local", "reliable") #call_local so the card references are the same for both peers
func synchronize_card_containers(card_container_path: String, card_data_array: Array) -> void:
	var card_container: CardContainer = get_node(card_container_path)
	for card in card_container.cards_node.get_children():
		card_container.remove_card(card)
	for card_data in card_data_array:
		var card: Card = CARD.instantiate()
		card.name = card_data["unique_id"]
		card_container.add_card(card)
		card.clicked.connect(_on_card_clicked)
		card.face_up_sprite.texture = load(card_data["texture"])

func _on_hand_button_pressed(hand: Hand):
	if hand.cards.is_empty():
		return
	if hand.is_being_searched:
		log_text.add_message("Can't look at a hand that is currently being searched.")
		return
	var scroll_hand_menu: ScrollHandMenu = SCROLL_HAND_MENU.instantiate()
	scroll_hand_menu.move_pressed.connect(_on_scroll_hand_menu_move_pressed.bind(hand))
	scroll_hand_menu.show_opponent_pressed.connect(_on_show_opponent_pressed)
	scroll_hand_menu.shuffle_pressed.connect(_on_shuffle_pressed.bind(hand))
	scroll_hand_menu.tree_exited.connect(_on_scroll_menu_tree_exited.bind(hand))
	menu_container.add_child(scroll_hand_menu)
	for card in hand.cards:
		scroll_hand_menu.add_card(card.duplicate())
	hand.is_being_searched = true

func _on_scroll_hand_menu_move_pressed(card_index: int, hand: Hand) -> void:
	_on_move_pressed(hand.cards[card_index])

func _on_opponent_hand_clicked(hand: Hand) -> void:
	if carried_card != null:
		return
	if hand.cards.is_empty():
		return
	var opponent_hand_menu: OpponentHandMenu = OPPONENT_HAND_MENU.instantiate()
	opponent_hand_menu.see_hand_pressed.connect(_on_see_opponent_hand_pressed.bind(hand))

	menu_container.add_child(opponent_hand_menu)
	opponent_hand_menu.center_container.global_position = hand.global_position

func _on_see_opponent_hand_pressed(hand: Hand):
	if hand.cards.is_empty():
		return
	if hand.is_being_searched:
		log_text.add_message("Can't look at a hand that is currently being searched.")
		return
	var scroll_hand_menu: ScrollHandMenu = SCROLL_HAND_MENU.instantiate()
	scroll_hand_menu.is_for_my_own_hand = false
	scroll_hand_menu.add_card_to_hand.connect(_on_add_card_to_hand.bind(hand))
	scroll_hand_menu.tree_exited.connect(_on_scroll_menu_tree_exited.bind(hand))
	menu_container.add_child(scroll_hand_menu)
	for card in hand.cards:
		var duplicate_card: Card = card.duplicate()
		duplicate_card.visible = true
		scroll_hand_menu.add_card(duplicate_card)
	hand.is_being_searched = true
