extends CharacterBody2D


const SPEED := 300.
const JUMP_VELOCITY := -400.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Peer id.
@export var peer_id : int : 
	set(value):
		peer_id = value
		name = str(peer_id)
		$Label.text = str(peer_id)
		set_multiplayer_authority(peer_id)


func _ready():
	# Set local camera.
	if peer_id == multiplayer.get_unique_id():
		var cam: Camera2D = Camera2D.new()
		add_child(cam)
	# Set process functions for current player.
	var is_local = is_multiplayer_authority()
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
