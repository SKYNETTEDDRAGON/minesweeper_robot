extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_alive = true

@onready var camera = $Camera3D

func _ready():
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_alive:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	if not is_alive:
		# Apply gravity when dead
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get input direction (WASD or arrow keys)
	var input_dir = Vector2.ZERO
	
	# Forward/Backward
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	
	# Left/Right
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	
	input_dir = input_dir.normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Check if stepped on a tile
	check_tile_collision()

func check_tile_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("tiles"):
			# Trigger tile click when landing on it
			if is_on_floor() and velocity.y <= 0:
				if collider.has_signal("tile_clicked"):
					collider.tile_clicked.emit(collider.grid_x, collider.grid_z)

func die():
	if not is_alive:
		return
	
	is_alive = false
	print("Player died!")
	
	# Ragdoll effect - launch upward
	velocity = Vector3(0, 15, 0) + Vector3(
		randf_range(-5, 5),
		0,
		randf_range(-5, 5)
	)
	
	# Tilt camera
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees", Vector3(
		randf_range(-45, 45),
		0,
		randf_range(-90, 90)
	), 1.0)
