extends RigidBody2D


@export var damage: float = 3




func die() -> void:
	queue_free()
