extends Item


@export var strength: float = 3


func on_picked_by(node: Node2D) -> void:
	if not node is Player:
		return
	if node.lost_hp:
		node.heal(strength)
		die()
