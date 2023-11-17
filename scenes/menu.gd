# Main menu
extends Control


func _process(_delta: float) -> void:
	Game.port = int(%RoomNum.text)


func _on_create_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Game.port)
	multiplayer.multiplayer_peer = peer
	Game.load_map()


func _on_connect_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", Game.port)
	multiplayer.multiplayer_peer = peer
	Game.load_map()
