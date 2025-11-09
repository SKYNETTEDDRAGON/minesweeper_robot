extends StaticBody3D

signal tile_clicked(x: int, z: int)

var is_mine: bool = false
var adjacent_mines: int = 0
var is_revealed: bool = false
var is_flagged: bool = false
var grid_x: int = 0
var grid_z: int = 0

@onready var mesh_instance = $MeshInstance3D
@onready var label = $Label3D
@onready var collision_shape = $CollisionShape3D

# Colors for different states
var unrevealed_color = Color(0.5, 0.5, 0.5)
var revealed_color = Color(0.8, 0.8, 0.8)
var mine_color = Color(1.0, 0.0, 0.0)
var flag_color = Color(1.0, 1.0, 0.0)

# Number colors (traditional minesweeper)
var number_colors = {
	1: Color(0.0, 0.0, 1.0),
	2: Color(0.0, 0.5, 0.0),
	3: Color(1.0, 0.0, 0.0),
	4: Color(0.0, 0.0, 0.5),
	5: Color(0.5, 0.0, 0.0),
	6: Color(0.0, 0.5, 0.5),
	7: Color(0.0, 0.0, 0.0),
	8: Color(0.5, 0.5, 0.5)
}

func _ready():
	# Ensure we have a MeshInstance3D
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1.8, 0.3, 1.8)
		mesh_instance.mesh = box_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = unrevealed_color
	mesh_instance.set_surface_override_material(0, material)
	
	# Setup label
	if not label:
		label = Label3D.new()
		add_child(label)
	
	label.position = Vector3(0, 0.2, 0)
	label.rotation_degrees = Vector3(-90, 0, 0)
	label.pixel_size = 0.01
	label.font_size = 64
	label.visible = false

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tile_clicked.emit(grid_x, grid_z)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			toggle_flag()

func toggle_flag():
	if is_revealed:
		return
	
	is_flagged = !is_flagged
	
	var material = mesh_instance.get_surface_override_material(0)
	if is_flagged:
		material.albedo_color = flag_color
		label.text = "🚩"
		label.visible = true
	else:
		material.albedo_color = unrevealed_color
		label.visible = false

func reveal():
	if is_revealed:
		return
	
	is_revealed = true
	is_flagged = false
	
	var material = mesh_instance.get_surface_override_material(0)
	
	if is_mine:
		material.albedo_color = mine_color
		label.text = "💣"
		label.modulate = Color.BLACK
		label.visible = true
	else:
		material.albedo_color = revealed_color
		
		if adjacent_mines > 0:
			label.text = str(adjacent_mines)
			label.modulate = number_colors.get(adjacent_mines, Color.BLACK)
			label.visible = true
		else:
			label.visible = false

func explode():
	reveal()
	
	# Create explosion effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale up and rotate
	tween.tween_property(self, "scale", Vector3(2, 2, 2), 0.3)
	tween.tween_property(self, "rotation_degrees", Vector3(
		randf_range(-180, 180),
		randf_range(-180, 180),
		randf_range(-180, 180)
	), 0.3)
	
	# Flash the material
	var material = mesh_instance.get_surface_override_material(0)
	tween.tween_property(material, "emission_enabled", true, 0.0)
	tween.tween_property(material, "emission", Color.RED, 0.0)
	tween.tween_property(material, "emission_energy", 5.0, 0.2)
	
	# Fade out
	tween.chain().tween_property(self, "scale", Vector3.ZERO, 0.2)
	
	# Apply impulse to nearby player
	var player = get_tree().get_first_node_in_group("player")
	if player and player is RigidBody3D:
		var direction = (player.global_position - global_position).normalized()
		var force = direction * 20.0 + Vector3.UP * 15.0
		player.apply_impulse(force, Vector3.ZERO)
