extends CardContainer
class_name Deck

@onready var center_container: CenterContainer = $CenterContainer
@onready var card_count: Label = $CenterContainer/CardCount

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
		card.visible = !value

func add_card(card: Card) -> void:
	super.add_card(card)
	card.to_field_size()
	card.control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.card_position = Card.Card_Position.FACE_DOWN_ATTACK
	card_count.text = str(cards.size())

func remove_card(card: Card) -> void:
	super.remove_card(card)
	card.control.mouse_filter = Control.MOUSE_FILTER_STOP
	card_count.text = str(cards.size())
	card.visible = true

@rpc("any_peer", "call_local", "reliable")
func move_card_to_bottom(card_path: String) -> void:
	var card: Card = get_node(card_path)
	cards.erase(card)
	cards.insert(0, card)
