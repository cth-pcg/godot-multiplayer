# Autoloaded script/singleton
# Added to the root location
# Manages game states
extends Node

@onready var main: Node = get_tree().root.get_node("Main")
@onready var players: Node = main.get_node("Players")
@onready var player_scene: PackedScene = preload("res://scenes/player_2d.tscn")
@onready var spectators: Node = main.get_node("Spectators")
@onready var spectator_scene: PackedScene = preload("res://scenes/spectator_camera.tscn")
@onready var items: Node = main.get_node("Items")
@onready var item_scene: PackedScene = preload("res://scenes/item.tscn")
@onready var bomb_scene: PackedScene = preload("res://scenes/bomb.tscn")


var port: int
var menu: Control = null
var map: Node = null
var player_spawn: Node2D = null
var item_spawn: Node2D = null


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
	
	player_spawn = map.get_node("PlayerSpawn")
	item_spawn = map.get_node("ItemSpawn")
	
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


func spawn_item() -> void:
	var i: Item = item_scene.instantiate()
	i.global_position = map.get_node("ItemSpawn").get_children().pick_random().global_position
	items.add_child(i)


func spawn_bomb() -> void:
	var b: Item = bomb_scene.instantiate()
	b.global_position = map.get_node("ItemSpawn").get_children().pick_random().global_position
	items.add_child(b)


func remove_player(id: int) -> void:
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()
