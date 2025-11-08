extends Node2D

@export var grid_width: int = 10
@export var grid_height: int = 10
@export var tile_width: float = 128.0
@export var tile_height: float = 64.0

@onready var flat_tile_scene = preload("res://FlatTileScene.tscn")
@onready var cube_tile_scene = preload("res://CubeTileScene.tscn")

func _ready():
	generate_grid()

func generate_grid():
	for y in range(grid_height):
		for x in range(grid_width):
			var is_edge = (x == 0 or y == 0 or x == grid_width - 1 or y == grid_height - 1)
			var tile_scene = cube_tile_scene if is_edge else flat_tile_scene
			var tile = tile_scene.instantiate()
			
			# Core isometric projection formula
			var iso_x = (x - y) * tile_width / 2
			var iso_y = (x + y) * tile_height / 2
			
			tile.position = Vector2(iso_x, iso_y)
			tile.z_index = x + y  # ensures correct draw order
			
			add_child(tile)
