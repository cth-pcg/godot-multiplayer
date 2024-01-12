# Main menu
extends Control


func _on_create_pressed() -> void:
	Game.port = int(%RoomNumEdit.text)
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Game.port)
	multiplayer.multiplayer_peer = peer
	Game.load_map()


func _on_connect_pressed() -> void:
	Game.port = int(%RoomNumEdit.text)
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", Game.port)
	multiplayer.multiplayer_peer = peer
	Game.send_player_info.rpc_id(1, %NameEdit.text, multiplayer.get_unique_id())
	print(GameManager.players)
	Game.load_map()
