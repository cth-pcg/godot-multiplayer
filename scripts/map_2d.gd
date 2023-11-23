extends Node2D


func _ready() -> void:
	$Floor/CollisionPolygon2D.polygon = $Floor/Polygon2D.polygon
