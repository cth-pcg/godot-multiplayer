extends CharacterBody2D


const SPEED: float = 500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2


func _ready()-> void:
	direction = Vector2(1, 0).rotated(rotation)


func _physics_process(delta) -> void:
	velocity = SPEED * direction
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()


func _on_area_2d_body_entered(body) -> void:
	if body is Player:
		body.damage()
	queue_free()
