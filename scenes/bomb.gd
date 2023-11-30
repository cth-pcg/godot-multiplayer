extends Item
class_name Bomb


func _on_area_2d_body_entered(bullet) -> void:
	$AnimationPlayer.play("boom")
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_area_2d_2_body_entered(player: Player) -> void:
	print((player.global_position - global_position).length())
	player.damage(300 / (player.global_position - global_position).length())
