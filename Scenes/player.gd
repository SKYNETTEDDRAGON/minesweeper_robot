extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_strength := 6.0
@export var mouse_sensitivity := 0.3
@export var gravity := 9.8

var velocity_y := 0.0
var cam_pitch := 0.0

@onready var cam = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		cam_pitch = clamp(cam_pitch - event.relative.y * mouse_sensitivity, -89, 89)
		cam.rotation_degrees.x = cam_pitch

func _physics_process(delta):
	var input_dir = Vector3.ZERO

	# Get input direction
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Convert local movement to global direction
	var direction = (transform.basis * input_dir).normalized()
	var velocity = Vector3.ZERO

	# Horizontal movement
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# Gravity
	if not is_on_floor():
		velocity_y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_strength
		else:
			velocity_y = 0.0

	velocity.y = velocity_y

	# Move the player
	move_and_slide()
	velocity_y = velocity.y
