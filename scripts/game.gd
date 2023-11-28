# Autoloaded script/singleton
# Added to the root location
# Manages game states
extends Node

@onready var main: Node = get_tree().root.get_node("Main")
@onready var players: Node = main.get_node("Players")
@onready var player_scene: PackedScene = preload("res://scenes/player_2d.tscn")
@onready var spectators: Node = main.get_node("Spectators")
@onready var spectator_scene: PackedScene = preload("res://scenes/spectator_camera.tscn")

var port: int
var menu: Control = null
var map: Node = null


func _ready() -> void:
	menu = preload("res://scenes/menu.tscn").instantiate()
	main.add_child(menu)
	
	# if multiplayer.is_server():
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)


func load_map() -> void:
	# #Free old stuff.
	if map != null:
		map.queue_free()
	if menu != null:
		menu.queue_free()
	
	# Spawn map.
	map = preload("res://scenes/map_2d.tscn").instantiate()
	main.add_child(map)
	
	# if multiplayer.is_server():
	var id = multiplayer.get_unique_id()
	print(1, " ", id)
	spawn_player(id)


@rpc("any_peer", "call_local")
func spawn_player(id: int) -> void:
	var p: Player = player_scene.instantiate()
	p.global_position = map.get_node("PlayerSpawn").get_children().pick_random().global_position
	p.peer_id = id
	print(multiplayer.is_server(), " ", p.peer_id)
	players.add_child(p, true)


func spawn_spectator() -> void:
	var o = spectator_scene.instantiate()
	spectators.add_child(o)


func remove_player(id: int) -> void:
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()
