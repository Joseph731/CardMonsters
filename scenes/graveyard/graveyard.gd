extends Deck

func add_card(card: Card) -> void:
	super.add_card(card)
	card.card_position = Card.Card_Position.FACE_UP_ATTACK
