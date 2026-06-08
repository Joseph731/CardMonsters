extends Control

var deck_select_menu: PackedScene = preload("uid://6y20t8is4ct5")

@onready var single_player_button: Button = $VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VBoxContainer/MultiplayerButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var options_button: Button = $VBoxContainer/OptionsButton

@onready var multiplayer_menu_scene: PackedScene = load("res://scenes/ui/multiplayer_menu/multiplayer_menu.tscn")

var options_menu_scene: PackedScene = preload("uid://p8amqxmylko3")


func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.pressed.connect(_on_options_pressed)
	
	UIAudioManager.register_buttons([
		single_player_button,
		multiplayer_button,
		quit_button,
		options_button
	])


func _on_single_player_button_pressed():
	get_tree().change_scene_to_packed(deck_select_menu)
	

func _on_multiplayer_button_pressed():
	get_tree().change_scene_to_packed(multiplayer_menu_scene)
	

func _on_quit_button_pressed():
	get_tree().quit()


func _on_options_pressed():
	var options_menu := options_menu_scene.instantiate()
	add_child(options_menu)
