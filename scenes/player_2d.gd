extends CharacterBody2D
class_name Player
## This character controller was created with the intent of being a decent starting point for Platformers.
## 
## Instead of teaching the basics, I tried to implement more advanced considerations.
## That's why I call it 'Movement 2'. This is a sequel to learning demos of similar a kind.
## Beyond coyote time and a jump buffer I go through all the things listed in the following video:
## https://www.youtube.com/watch?v=2S3g8CgBG1g
## Except for separate air and ground acceleration, as I don't think it's necessary.


# BASIC MOVEMENT VARAIABLES
var input_dir: float = 0

@export var max_speed: float = 560
@export var acceleration: float = 2880
@export var turning_acceleration: float = 9600
@export var deceleration: float = 3200

# GRAVITY
@export var gravity_acceleration: float = 3840
@export var gravity_max: float = 1020

# JUMP VARAIABLES
@export var jump_force: float = 1400
@export var jump_cut: float = .25
@export var jump_gravity_max: float = 500
@export var jump_hang_treshold: float = 2.
@export var jump_hang_gravity_mult: float = .1

# Timers
@export var jump_coyote: float = .08
@export var jump_buffer: float = .1

@export var bullet: PackedScene

var jump_coyote_timer: float = 0
var jump_buffer_timer: float = 0
var is_jumping: bool = false

var previous_velocity: Vector2 = Vector2(0, 0)
var hp: int = 10

# Peer id.
@export var peer_id: int:
	set(value):
		peer_id = value
		name = str(peer_id)
		$IDLabel.text = "ID: " + str(peer_id)
		set_multiplayer_authority(peer_id)

@onready var animator: AnimationPlayer = $Sprite/AnimationPlayer
@onready var cam_scene: PackedScene = preload("res://scenes/player_camera.tscn")


func _ready():
	# Set local camera.
	if peer_id == multiplayer.get_unique_id():
		var cam_inst: Camera2D = cam_scene.instantiate()
		add_child(cam_inst)
	# Set process functions for current player.
	var is_local := is_multiplayer_authority()
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)


func _physics_process(delta: float) -> void:
	input_dir = Input.get_axis("move_left", "move_right")
	if hp <= 0:
		die.rpc()
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)
	animation()
	shooting_logic()
	timers(delta)
	move_and_slide()
	
	$HPLabel.text = "HP: " + str(hp)


@rpc("any_peer", "call_local")
func die() -> void:
	queue_free()


func x_movement(delta: float) -> void:
	# Stop if we're not doing movement inputs.
	if not input_dir:
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0, 0), deceleration * delta).x
		return
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == input_dir:
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	var accel_rate: float = acceleration if sign(velocity.x) == input_dir else turning_acceleration
	
	# Accelerate
	velocity.x += input_dir * accel_rate * delta


func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		jump_coyote_timer = 0
		jump_buffer_timer = 0
		# If falling, account for that lost speed
		if velocity.y > 0:
			velocity.y -= velocity.y
		
		velocity.y = -jump_force
	
	# We're not actually interested in checking if the player is holding the jump button
#	if get_input()["jump"]:pass
	
	# Cut the velocity if let go of jump. This means our jumpheight is varaiable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func apply_gravity(delta: float) -> void:
	var applied_gravity: float = 0
	
	# No gravity if we are grounded
	if jump_coyote_timer > 0:
		return
	
	# Normal gravity limit
	if velocity.y <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	
	velocity.y += applied_gravity


func animation() -> void:
	if previous_velocity.y >= 0 and velocity.y < 0:
		animator.play("jump")
	elif previous_velocity.y > 0 and is_on_floor():
		animator.play("land")
	previous_velocity = velocity
	$Muzzle.look_at(get_global_mouse_position())


@rpc("any_peer", "call_local")
func shoot() -> void:
	var b: CharacterBody2D = bullet.instantiate()
	b.global_position = $Muzzle/BulletSpawn.global_position
	b.rotation = $Muzzle.rotation
	get_tree().root.add_child(b)


func shooting_logic() -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta
