extends Camera2D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		Game.spawn_player.rpc(multiplayer.get_unique_id())
		queue_free()
