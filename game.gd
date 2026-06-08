class_name Main
extends Node

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/main_menu/main_menu.tscn"

@onready var pause_menu: PauseMenu = $PauseMenu
@onready var lobby_manager: LobbyManager = $LobbyManager
@onready var game_blocker: Control = $GameBlocker

func _ready():
	peer_ready.rpc_id(1, MultiplayerConfig.display_name)
	pause_menu.quit_requested.connect(_on_quit_requested)
	lobby_manager.all_peers_ready.connect(_on_all_peers_ready)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(_peer_id: int) -> void:
	# 3. Close the server to any future connections
	var peer = multiplayer.multiplayer_peer
	if peer is ENetMultiplayerPeer:
		peer.refuse_new_connections = true
		print("Server is now CLOSED to new players. Game on!")

@rpc("any_peer", "call_local", "reliable")
func peer_ready(_display_name: String):
	pass

func end_game():
	get_tree().paused = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func get_all_peers() -> PackedInt32Array:
	var all_peers := multiplayer.get_peers()
	all_peers.push_back(multiplayer.get_unique_id())
	return all_peers

func _on_server_disconnected():
	end_game()

func _on_peer_disconnected(_peer_id: int):
	end_game()

func _on_game_completed():
	end_game()

func _on_quit_requested():
	end_game()

func _on_all_peers_ready():
	lobby_manager.close_lobby()
	if is_multiplayer_authority():
		remove_game_blocker.rpc()

@rpc("authority", "call_local", "reliable")
func remove_game_blocker() -> void:
	game_blocker.queue_free()
