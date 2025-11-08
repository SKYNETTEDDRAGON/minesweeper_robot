extends Node

@export var grid_width: int = 10
@export var grid_height: int = 10
@export var mine_count: int = 15
@export var tile_size: float = 2.0

var tile_scene = preload("res://Scenes/tile.tscn")
var grid = []

func _ready():
	print("GameManager started :D")
	add_to_group("game_manager")
	generate_grid()

func generate_grid():
	# Clear existing tiles
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.queue_free()
	grid.clear()
	
	# Create grid array
	for x in range(grid_width):
		grid.append([])
		for z in range(grid_height):
			var tile = tile_scene.instantiate()
			add_child(tile)
			tile.add_to_group("tiles")
			tile.position = Vector3(x * tile_size, 0, z * tile_size)
			grid[x].append(tile)
	
	# Place mines randomly
	place_mines()
	
	# Calculate adjacent mine counts
	calculate_numbers()

func place_mines():
	var placed_mines = 0
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	while placed_mines < mine_count:
		var x = rng.randi_range(0, grid_width - 1)
		var z = rng.randi_range(0, grid_height - 1)
		
		if not grid[x][z].is_mine:
			grid[x][z].is_mine = true
			placed_mines += 1

func calculate_numbers():
	for x in range(grid_width):
		for z in range(grid_height):
			if not grid[x][z].is_mine:
				grid[x][z].adjacent_mines = count_adjacent_mines(x, z)

func count_adjacent_mines(x: int, z: int) -> int:
	var count = 0
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			if dx == 0 and dz == 0:
				continue
			var nx = x + dx
			var nz = z + dz
			if nx >= 0 and nx < grid_width and nz >= 0 and nz < grid_height:
				if grid[nx][nz].is_mine:
					count += 1
	return count

func game_over():
	print("Game Over! You hit a mine!")
	# Reveal all tiles or restart
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
