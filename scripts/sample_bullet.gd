extends CharacterBody2D


const SPEED: float = 1200
const GRAVITY_SCALE: float = 2
const AIR_FRICTION: float = 10
const DAMAGE: int = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var shooter_id: int


func _ready() -> void:
	direction = Vector2(1, 0).rotated(rotation)
	velocity = direction * SPEED


func _physics_process(delta) -> void:
	velocity.x = move_toward(velocity.x, 0, AIR_FRICTION)
	velocity.y += gravity * GRAVITY_SCALE * delta
	move_and_slide()


func _on_area_2d_body_entered(body) -> void:
	if body is Player:
		if body.peer_id != shooter_id:
			body.damage(DAMAGE)
		if not body.hp:
			body.killer_id = shooter_id
	queue_free()
