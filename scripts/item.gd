extends RigidBody2D
class_name Item


func on_picked_by(_node) -> void:
	pass


func damage() -> void:
	pass


func die() -> void:
	queue_free()
