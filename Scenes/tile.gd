extends StaticBody3D

@export var is_mine: bool = false
@export var adjacent_mines: int = 0
var is_revealed: bool = false

@onready var mesh_instance = $MeshInstance3D
@onready var area = $Area3D

var safe_material = StandardMaterial3D.new()
var mine_material = StandardMaterial3D.new()
var number_materials = {}

func _ready():
	setup_materials()
	area.body_entered.connect(_on_body_entered)
func setup_materials():
	safe_material.albedo_color = Color.GREEN
	mine_material.albedo_color = Color.RED
func _on_body_entered(body):
	if body.is_in_group("player") and not is_revealed:
		reveal()

func reveal():
	is_revealed = true
	if is_mine:
		mesh_instance.material_override = mine_material
		get_tree().call_group("game_manager", "game_over")
	else:
		mesh_instance.material_override = safe_material
		show_number()

func show_number():
	if adjacent_mines > 0:
		pass
