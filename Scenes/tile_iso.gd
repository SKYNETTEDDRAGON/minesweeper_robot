extends Node

@export var grid_pos: Vector2i
var has_mine: bool = false
var revealed: bool = false
var mine_count: int = 0

func reveal():
	if revealed:
		return
	revealed = true
	if has_mine:
		$tile.modulate = Color(1,0.2,0.2)
	else:
		$tile.modulate = Color(0.8,0.9,1.0)
		$mine_count.text = str(mine_count) if mine_count >0 else ""
		 
