extends MarginContainer

@onready var back_button: Button = %BackButton
@onready var deck_id_0_button: TextureButton = %DeckID0Button
@onready var deck_id_1_button: TextureButton = %DeckID1Button

@onready var main_menu_scene: PackedScene = load("uid://cepkpyuudi5tm")

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	deck_id_0_button.pressed.connect(_on_deck_id_0_button_pressed)
	deck_id_1_button.pressed.connect(_on_deck_id_1_button_pressed)
	
	UIAudioManager.register_buttons([
		back_button,
		deck_id_0_button,
		deck_id_1_button
	])

func _on_deck_id_0_button_pressed() -> void:
	MultiplayerConfig.deck_id = 0

func _on_deck_id_1_button_pressed() -> void:
	MultiplayerConfig.deck_id = 1

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
