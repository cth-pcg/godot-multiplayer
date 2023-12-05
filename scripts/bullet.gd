extends CharacterBody2D


@export var speed: float = 1200
@export var strength: float = 1

const GRAVITY_SCALE: float = 2
const AIR_FRICTION: float = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var life_time: float = 3
var direction: Vector2
var shooter_id: int


func _ready() -> void:
	direction = Vector2(1, 0).rotated(rotation)
	velocity = direction * speed


func _physics_process(delta) -> void:
	if not life_time:
		die()
	velocity.x = move_toward(velocity.x, 0, AIR_FRICTION)
	velocity.y += gravity * GRAVITY_SCALE * delta
	move_and_slide()
	life_time = max(0, life_time - delta)


func _on_collision_detector_body_entered(body) -> void:
	die()
	if body is Player:
		if body.peer_id != shooter_id:
			body.damage(strength)
	if body is Item:
		body.damage()
	


func die() -> void:
	queue_free()

