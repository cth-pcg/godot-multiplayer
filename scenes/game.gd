# Autoloaded script/singleton
# Added to the root location
# Manages game states
extends Node

const PORT: int = 1337

@onready var main: Node = get_tree().root.get_node("Main")
@onready var players: Node = main.get_node("Players")
@onready var player_scene: PackedScene = preload("res://scenes/player_2d.tscn")

var menu: Control = null
var map: Node = null


func _ready() -> void:
	menu = preload("res://scenes/menu.tscn").instantiate()
	main.add_child(menu)
	
	# if multiplayer.is_server():
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)


func load_map() -> void:
	# Free old stuff.
	if map != null:
		map.queue_free()
	if menu != null:
		menu.queue_free()
	
	# Spawn map.
	map = preload("res://scenes/map_2d.tscn").instantiate()
	main.add_child(map)
	
	# if multiplayer.is_server():
	spawn_player(multiplayer.get_unique_id())


func spawn_player(id: int) -> void:
	var player: Player = player_scene.instantiate()
	player.peer_id = id
	players.add_child(player, true)


func remove_player(id: int) -> void:
	if not players.has_node(str(id)):
		return
	players.get_node(str(id)).queue_free()


func respawn_player(id: int) -> void:
	if Input.is_action_just_pressed("respawn"):
		players.get_node(str(id)).initialize.rpc()
