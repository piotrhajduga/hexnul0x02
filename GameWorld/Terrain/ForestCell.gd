extends Spatial

var world_data
onready var game_space = get_node("/root/GameSpace")
onready var Tree = preload("res://GameWorld/Terrain/Tree.tscn")

export(int) var radius = 1

func _ready():
	for offset in game_space.offset_range(Vector2(0,0),radius):
		var pos = game_space.offset_to_world(offset) / (2*radius+1)
		var tree = Tree.instance()
		tree.translation = pos
		tree.translation.y = world_data.get_terrain_mesh_height(to_global(pos))
		add_child(tree)