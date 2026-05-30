extends Deck

@export var is_face_up: bool = true

func add_card(card: Card) -> void:
	super.add_card(card)
	if is_face_up:
		card.card_position = Card.Card_Position.FACE_UP_ATTACK
	else:
		card.card_position = Card.Card_Position.FACE_DOWN_ATTACK
