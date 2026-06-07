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
const ALLOW_MENU = preload("uid://bl3c7o2xghr66")
const TOKEN_MENU = preload("uid://xwn5jpc2h4jf")

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
@onready var coin: TextureButton = $Coin
@onready var menu_container: CanvasLayer = $MenuContainer
@onready var log_text: LogText = $LogCanvasLayer/LogText

var my_monster_zones: Array[CardContainer]
var opponent_monster_zones: Array[CardContainer]
var my_spell_zones: Array[CardContainer]
var opponent_spell_zones: Array[CardContainer]
var my_deck: Deck
var opponent_deck: Deck
var my_extra_deck: Deck
var opponent_extra_deck: Deck
var my_hand: Hand
var opponent_hand: Hand
var my_graveyard: Deck
var opponent_graveyard: Deck
var my_banished: Deck
var opponent_banished: Deck

var deck_dictionary: Dictionary[String, Deck]

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
		my_deck = deck1
		opponent_deck = deck2
		my_extra_deck = extra_deck1
		opponent_extra_deck = extra_deck2
		my_hand = hand1
		opponent_hand = hand2
		my_graveyard = graveyard1
		opponent_graveyard = graveyard2
		my_banished = banished1
		opponent_banished = banished2
		
		my_spell_zones.assign(spell_zone1.get_children())
		opponent_spell_zones.assign(spell_zone2.get_children())
		my_monster_zones.assign(monster_zone1.get_children())
		opponent_monster_zones.assign(monster_zone2.get_children())
		
		hand_button.pressed.connect(_on_hand_button_pressed.bind(hand1))
	else:
		my_deck = deck2
		opponent_deck = deck1
		my_extra_deck = extra_deck2
		opponent_extra_deck = extra_deck1
		my_hand = hand2
		opponent_hand = hand1
		my_graveyard = graveyard2
		opponent_graveyard = graveyard1
		my_banished = banished2
		opponent_banished = banished1
		
		my_spell_zones.assign(spell_zone2.get_children())
		opponent_spell_zones.assign(spell_zone1.get_children())
		my_monster_zones.assign(monster_zone2.get_children())
		opponent_monster_zones.assign(monster_zone1.get_children())
		
		hand_button.pressed.connect(_on_hand_button_pressed.bind(hand2))
	
	deck_dictionary["my_deck"] = my_deck
	deck_dictionary["opponent_deck"] = opponent_deck
	deck_dictionary["my_extra_deck"] = my_extra_deck
	deck_dictionary["opponent_extra_deck"] = opponent_extra_deck
	deck_dictionary["my_graveyard"] = my_graveyard
	deck_dictionary["opponent_graveyard"] = opponent_graveyard
	deck_dictionary["my_banished"] = my_banished
	deck_dictionary["opponent_banished"] = opponent_banished
	
	opponent_hand.collision_shape_2d.shape = opponent_hand.collision_shape_2d.shape.duplicate()
	opponent_hand.collision_shape_2d.shape.size = opponent_hand_visual.get_custom_minimum_size()
	opponent_hand.global_position = opponent_hand_visual.global_position + opponent_hand.collision_shape_2d.shape.size / 2
	opponent_hand.card_count_changed.connect(opponent_hand_visual.on_hand_card_count_changed)
	
	opponent_deck.center_container.rotation_degrees = 180
	
	opponent_hand.clicked.connect(_on_opponent_hand_clicked)
	
	coin.flipped.connect(_on_coin_flipped)
	
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
			if menu_container.get_children().back() is not AllowMenu:
				menu_container.get_children().back().queue_free()
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
		var enemy_zones: Array[CardContainer]
		enemy_zones.assign(opponent_spell_zones)
		enemy_zones.append_array(opponent_monster_zones)
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
		if card_container is not Hand && card_container is not Deck && card_container.cards.is_empty():
			var token_menu: TokenMenu = TOKEN_MENU.instantiate()
			token_menu.create_token_pressed.connect(_on_create_token_pressed.bind(card_container))
			menu_container.add_child(token_menu)
			token_menu.center_container.global_position = card_container.global_position
		return
		
	
	if (card_container.enforce_occupied && card_container.cards.size() > 0
			&& card_container.cards[0] != carried_card):
		return
	
	if carried_card.is_token && (card_container is Deck || card_container is Hand):
		var token: Card = carried_card
		carried_card = null
		token.delete.rpc()
		log_text.add_message.rpc("Token was destroyed.")
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
	if (deck != deck1 && deck != deck2) || deck == opponent_deck:
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
	
	var deck_dictionary_key: String
	match deck:
		my_deck: deck_dictionary_key = "my_deck"
		opponent_deck: deck_dictionary_key = "opponent_deck"
		my_extra_deck: deck_dictionary_key = "my_extra_deck"
		opponent_extra_deck: deck_dictionary_key = "opponent_extra_deck"
		my_graveyard: deck_dictionary_key = "my_graveyard"
		opponent_graveyard: deck_dictionary_key = "opponent_graveyard"
		my_banished: deck_dictionary_key = "my_banished"
		opponent_banished: deck_dictionary_key = "opponent_banished"
	
	if deck != opponent_deck && deck != opponent_extra_deck:
		create_scroll_deck_menu(deck_dictionary_key)
	else:
		show_allow_menu.rpc("Allow Opponent to search " + deck.custom_name + "?" , "_on_allow_see_deck_pressed", "Your opponent declined your search request.", deck_dictionary_key)

@rpc("any_peer", "call_remote", "reliable")
func create_scroll_deck_menu(deck_dictionary_key: String) -> void:
	var deck: Deck = deck_dictionary[deck_dictionary_key]
	
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

func _on_allow_see_deck_pressed(deck_dictionary_key: String) -> void:
	create_scroll_deck_menu.rpc(deck_dictionary_key)

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
	if card_container is Hand:
		card_container.update_card_positions()
	
	var card_data_array: Array
	for card in card_container.cards:
		var unique_id: String = str(ResourceUID.create_id())
		card.name = unique_id
		card_data_array.append({"texture": card.face_up_sprite.texture.resource_path,
			"unique_id": unique_id})
	synchronize_card_containers.rpc(card_container.get_path(), card_data_array)
	log_text.add_message.rpc(card_container.custom_name + " was shuffled.")

@rpc("any_peer", "call_remote", "reliable") #call_local so the card references are the same for both peers
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
		if card_data.has("card_position"):
			card.card_position = card_data["card_position"]
		if card_data.has("is_token"):
			card.is_token = card_data["is_token"]

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
	
	show_allow_menu.rpc("Allow Opponent to see Hand?", "_on_allow_see_hand_yes_pressed", "Your opponent declined your request to see their hand.")

@rpc("any_peer", "call_remote", "reliable")
func show_allow_menu(allow_menu_text: String, _on_allow_menu_yes_pressed: String, decline_message: String, deck_dictionary_key: String = "") -> void:
	if menu_container.get_child_count() != 0:
		if menu_container.get_children().back() is AllowMenu:
			return
	var allow_menu: AllowMenu = ALLOW_MENU.instantiate()
	if deck_dictionary_key == "":
		allow_menu.yes_pressed.connect(Callable(self, _on_allow_menu_yes_pressed))
	else:
		allow_menu.yes_pressed.connect(_on_allow_see_deck_pressed.bind(deck_dictionary_key))
	allow_menu.no_pressed.connect(_on_allow_menu_no_pressed.bind(decline_message))
	menu_container.add_child(allow_menu)
	allow_menu.label.text = allow_menu_text

func _on_allow_see_hand_yes_pressed() -> void:
	create_scroll_opponent_hand_menu.rpc()

func _on_allow_menu_no_pressed(decline_message: String) -> void:
	var peer_id = multiplayer.get_peers()[0]
	log_text.add_message.rpc_id(peer_id, decline_message)

@rpc("any_peer", "call_remote", "reliable")
func create_scroll_opponent_hand_menu() -> void:
	var scroll_hand_menu: ScrollHandMenu = SCROLL_HAND_MENU.instantiate()
	menu_container.add_child(scroll_hand_menu)
	scroll_hand_menu.is_for_my_own_hand = false
	scroll_hand_menu.add_card_to_hand.connect(_on_add_card_to_hand.bind(opponent_hand))
	scroll_hand_menu.tree_exited.connect(_on_scroll_menu_tree_exited.bind(opponent_hand))
	for card in opponent_hand.cards:
		var duplicate_card: Card = card.duplicate()
		duplicate_card.visible = true
		scroll_hand_menu.add_card(duplicate_card)
	opponent_hand.is_being_searched = true

func _on_coin_flipped(landed_on_heads: bool):
	var coin_result: String
	if landed_on_heads:
		coin_result = "Heads"
	else:
		coin_result = "Tails"
	log_text.add_message.rpc("Coin landed on " + coin_result + ".")

func _on_create_token_pressed(card_container: CardContainer) -> void:
	var token: Card = CARD.instantiate()
	token.is_token = true
	token.clicked.connect(_on_card_clicked)
	card_container.add_card(token)
	token.card_position = Card.Card_Position.FACE_UP_ATTACK
	
	var card_data_array: Array
	for card in card_container.cards:
		var unique_id: String = str(ResourceUID.create_id())
		card.name = unique_id
		card_data_array.append({"texture": card.face_up_sprite.texture.resource_path,
			"unique_id": unique_id, "card_position": card.card_position, "is_token": card.is_token})
	synchronize_card_containers.rpc(card_container.get_path(), card_data_array)
