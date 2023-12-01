extends RigidBody2D
class_name Item


@export var strength: float


func on_picked_by(_node) -> void:
	pass


func die() -> void:
	queue_free()
