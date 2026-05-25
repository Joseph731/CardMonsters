extends CardContainer

func add_card(card: Card) -> void:
	super.add_card(card)
	card.area_2d.input_pickable = false
	card.card_position = Card.Card_Position.FACE_DOWN_ATTACK

func remove_card(card: Card) -> void:
	super.remove_card(card)
	card.area_2d.input_pickable = true
