extends Item


func _ready():
	strength = 3


func on_picked_by(node: Node2D) -> void:
	if not node is Player:
		return
	if node.lost_hp:
		node.heal(strength)
		die()
