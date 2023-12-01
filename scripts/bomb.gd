extends Item


func _ready():
	strength = 100


func _on_area_2d_body_entered(_bullet) -> void:
	$AnimationPlayer.play("boom")
	await $AnimationPlayer.animation_finished
	die()


func _on_area_2d_2_body_entered(player: Player) -> void:
	var distance: Vector2 = player.global_position - global_position
	print(distance.length())
	player.damage(200 / distance.length())
	player.velocity += Vector2(50, 1) * 1000 / distance
