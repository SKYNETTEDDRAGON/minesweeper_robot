extends Node2D

const TILE_WIDTH := 128
const TILE_HEIGHT := 64
const GRID_SIZE := Vector2i(10, 10)
const MINE_COUNT := 15

var tiles: Array = []  # 2D array of all tiles

@onready var TileScene = preload("res://scenes/tile_iso.tscn")

func _ready():
	generate_grid()
	place_mines()
	calculate_numbers()


func center_camera():
	var center = grid_to_iso(GRID_SIZE.x / 2, GRID_SIZE.y / 2)
	$Camera2D.position = center


func generate_grid():
	tiles.clear()
	for y in range(GRID_SIZE.y):
		var row: Array = []
		for x in range(GRID_SIZE.x):
			var tile = TileScene.instantiate()
			var iso_pos = grid_to_iso(x, y)
			tile.position = iso_pos
			tile.grid_pos = Vector2i(x, y)
			add_child(tile)
			row.append(tile)
		tiles.append(row)
		center_camera()

# Converts (x, y) to screen position
func grid_to_iso(x: int, y: int) -> Vector2:
	return Vector2(
		(x - y) * TILE_WIDTH / 2,
		(x + y) * TILE_HEIGHT / 2
	)

# Converts screen position to grid coordinates (optional)
func iso_to_grid(pos: Vector2) -> Vector2i:
	var x = (pos.x / (TILE_WIDTH / 2) + pos.y / (TILE_HEIGHT / 2)) / 2
	var y = (pos.y / (TILE_HEIGHT / 2) - pos.x / (TILE_WIDTH / 2)) / 2
	return Vector2i(round(x), round(y))

# -----------------------------------------
# STEP 2: Place Mines Randomly
# -----------------------------------------
func place_mines():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var placed = 0
	while placed < MINE_COUNT:
		var x = rng.randi_range(0, GRID_SIZE.x - 1)
		var y = rng.randi_range(0, GRID_SIZE.y - 1)
		var tile = tiles[y][x]
		if not tile.has_mine:
			tile.has_mine = true
			placed += 1

# -----------------------------------------
# STEP 3: Calculate Adjacent Mine Numbers
# -----------------------------------------
func calculate_numbers():
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var tile = tiles[y][x]
			if tile.has_mine:
				continue
			var count = 0
			for ny in range(y - 1, y + 2):
				for nx in range(x - 1, x + 2):
					if nx == x and ny == y:
						continue
					if is_in_bounds(nx, ny) and tiles[ny][nx].has_mine:
						count += 1
			tile.mine_count = count

func is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < GRID_SIZE.x and y < GRID_SIZE.y

	
