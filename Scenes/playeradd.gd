extends Node3D

@export var player_scene: PackedScene
@onready var spawn_point = $PlayerSpawn

func _ready():
	# Instance the player
	var player = player_scene.instantiate()
	
	# Set position to spawn point
	player.global_transform.origin = spawn_point.global_transform.origin

	# Add player to scene
	add_child(player)
