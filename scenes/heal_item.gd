extends RigidBody2D


@export var heal: float = 3


func _on_area_2d_body_entered(body):
	if not body is Player:
		return
	if body.lost_hp:
		body.heal(heal)
		die()


func die() -> void:
	queue_free()
