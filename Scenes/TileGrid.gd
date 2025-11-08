extends Node2D

@export var grid_width: int = 10
@export var grid_height: int = 10
@export var flat_tile_scene: PackedScene
@export var cube_tile_scene: PackedScene
@export var tile_width: float = 64.0
@export var tile_height: float = 32.0

func _ready():
	generate_grid()

func generate_grid():
	for y in range(grid_height):
		for x in range(grid_width):
			# Check if tile is at border
			var is_edge = (x == 0 or y == 0 or x == grid_width - 1 or y == grid_height - 1)

			var tile_scene = cube_tile_scene if is_edge else flat_tile_scene
			var tile = tile_scene.instantiate()

			var iso_x = (x - y) * (tile_width / 2)
			var iso_y = (x + y) * (tile_height / 2)

			tile.position = Vector2(iso_x, iso_y)
			tile.z_index = x + y
			add_child(tile)

	# Center grid in view
	position = Vector2(get_viewport_rect().size.x / 2, 100)
