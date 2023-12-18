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

@rpc("any_peer", "call_remote")
func set_state(v, life_time):
	velocity = v
	life_time = life_time

@rpc("any_peer", "call_remote")
func physics_process(delta, v, life_time):
	v.x = move_toward(v.x, 0, AIR_FRICTION)
	v.y += gravity * GRAVITY_SCALE * delta
	life_time = max(0, life_time - delta)
	set_state.rpc_id(multiplayer.get_remote_sender_id(), v, life_time)


func _physics_process(delta) -> void:
	if not life_time:
		die()
	if multiplayer.is_server():
		physics_process(delta, velocity, life_time)
	else:
		physics_process.rpc_id(1, delta, velocity, life_time)
	move_and_slide()


func _on_collision_detector_body_entered(body) -> void:
	die()
	if body is Player:
		if body.peer_id != shooter_id:
			body.damage(strength)
	if body is Item:
		body.damage()
	


func die() -> void:
	queue_free()

