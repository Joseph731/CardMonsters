extends CardContainer
class_name Hand

const CARD = preload("uid://cguukq18jkrx2") #TEMP FOR DEVELOPMENT

@export var ServersHand: bool = true

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var _is_being_searched: bool
var is_being_searched: bool:
	get:
		return _is_being_searched
	set(value):
		set_is_being_searched.rpc(value)

@rpc("any_peer", "call_local", "reliable")
func set_is_being_searched(value: bool) -> void:
	_is_being_searched = value
	for card in cards:
		if value:
			card.face_up_sprite.modulate = Color.GRAY
			card.control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			card.face_up_sprite.modulate = Color.WHITE
			card.control.mouse_filter = Control.MOUSE_FILTER_STOP

func update_card_positions() -> void:
	var hand_count: int = cards.size()
	match hand_count:
		1:
			cards[0].position.x = 0
		2:
			cards[0].position.x = -92
			cards[1].position.x = 92
		3:
			cards[0].position.x = -184
			cards[1].position.x = 0
			cards[2].position.x = 184
		4:
			cards[0].position.x = -276
			cards[1].position.x = -92
			cards[2].position.x = 92
			cards[3].position.x = 276
		5:
			cards[0].position.x = -368
			cards[1].position.x = -184
			cards[2].position.x = 0
			cards[3].position.x = 184
			cards[4].position.x = 368
		6:
			cards[0].position.x = -460
			cards[1].position.x = -276
			cards[2].position.x = -92
			cards[3].position.x = 92
			cards[4].position.x = 276
			cards[5].position.x = 460
		7:
			cards[0].position.x = -552
			cards[1].position.x = -368
			cards[2].position.x = -184
			cards[3].position.x = 0
			cards[4].position.x = 184
			cards[5].position.x = 368
			cards[6].position.x = 552
		8:
			cards[0].position.x = -644
			cards[1].position.x = -460
			cards[2].position.x = -276
			cards[3].position.x = -92
			cards[4].position.x = 92
			cards[5].position.x = 276
			cards[6].position.x = 460
			cards[7].position.x = 644
		9:
			cards[0].position.x = -736
			cards[1].position.x = -552
			cards[2].position.x = -368
			cards[3].position.x = -184
			cards[4].position.x = 0
			cards[5].position.x = 184
			cards[6].position.x = 368
			cards[7].position.x = 552
			cards[8].position.x = 736
		10:
			cards[0].position.x = -828
			cards[1].position.x = -644
			cards[2].position.x = -460
			cards[3].position.x = -276
			cards[4].position.x = -92
			cards[5].position.x = 92
			cards[6].position.x = 276
			cards[7].position.x = 460
			cards[8].position.x = 644
			cards[9].position.x = 828

func add_card(card: Card) -> void:
	super.add_card(card)
	card.position.y = 0
	card.to_hand_size()
	update_card_positions()
	if ((ServersHand && !is_multiplayer_authority()) ||
		(!ServersHand && is_multiplayer_authority())):
			card.visible = false
	card.card_position = Card.Card_Position.FACE_UP_ATTACK

func remove_card(card: Card) -> void:
	super.remove_card(card)
	update_card_positions()
	card.visible = true
	card.face_up_sprite.modulate = Color.WHITE
	card.control.mouse_filter = Control.MOUSE_FILTER_STOP
