extends Control

@onready var label: Label = $PanelContainer/Label

func on_hand_card_count_changed(new_card_count: int):
	label.text = "Opponent's Hand: " + str(new_card_count)
