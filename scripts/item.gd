extends RigidBody2D
class_name Item


@export var heal: float = 3


func on_picked_by(node: Node2D) -> void:
	if not node is Player:
		return
	if node.lost_hp:
		node.heal(heal)
		die()


func die() -> void:
	queue_free()
