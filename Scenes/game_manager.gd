extends Node

@export var grid_width: int = 10
@export var grid_height: int = 10
@export var mine_count: int = 15
@export var tile_size: float = 2.0

var tile_scene = preload("res://Scenes/tile.tscn")
var grid = []
var game_active = true

func _ready():
	print("GameManager started :D")
	add_to_group("game_manager")
	generate_grid()

func generate_grid():
	# Clear existing tiles
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.queue_free()
	
	grid.clear()
	game_active = true
	
	# Create grid array
	for x in range(grid_width):
		grid.append([])
		for z in range(grid_height):
			var tile = tile_scene.instantiate()
			add_child(tile)
			tile.add_to_group("tiles")
			tile.position = Vector3(x * tile_size, 0, z * tile_size)
			tile.grid_x = x
			tile.grid_z = z
			
			# Connect tile signal
			if tile.has_signal("tile_clicked"):
				tile.tile_clicked.connect(_on_tile_clicked)
			
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

func _on_tile_clicked(x: int, z: int):
	if not game_active:
		return
	
	var tile = grid[x][z]
	
	if tile.is_revealed or tile.is_flagged:
		return
	
	# If it's a mine, trigger explosion
	if tile.is_mine:
		tile.explode()
		game_over()
	else:
		# Reveal tile and cascade if it's a zero
		reveal_tile(x, z)

func reveal_tile(x: int, z: int):
	if x < 0 or x >= grid_width or z < 0 or z >= grid_height:
		return
	
	var tile = grid[x][z]
	
	if tile.is_revealed or tile.is_mine or tile.is_flagged:
		return
	
	tile.reveal()
	
	# If this tile has no adjacent mines, reveal all neighbors (cascade)
	if tile.adjacent_mines == 0:
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dz == 0:
					continue
				reveal_tile(x + dx, z + dz)

func game_over():
	if not game_active:
		return
	
	game_active = false
	print("Game Over! You hit a mine!")
	
	# Reveal all mines
	for x in range(grid_width):
		for z in range(grid_height):
			if grid[x][z].is_mine:
				grid[x][z].reveal()
	
	# Kill player if exists
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("die"):
		player.die()
	
	# Restart after delay
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

func check_win():
	var revealed_count = 0
	var total_safe_tiles = grid_width * grid_height - mine_count
	
	for x in range(grid_width):
		for z in range(grid_height):
			if grid[x][z].is_revealed and not grid[x][z].is_mine:
				revealed_count += 1
	
	if revealed_count == total_safe_tiles:
		win_game()

func win_game():
	game_active = false
	print("You Win! All safe tiles revealed!")
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
