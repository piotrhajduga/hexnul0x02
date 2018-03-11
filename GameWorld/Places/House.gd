extends Spatial

onready var game_space = get_node("/root/GameSpace")

var world_data
var game_position = Vector2()

func _ready():
	self.translation = world_data.get_world_pos(game_position)
	var neighbors = game_space.offset_neighbors(game_position)
	look_at_cell(neighbors[randi()%6])
	for objects in get_children():
		objects.translation.y = world_data.get_terrain_mesh_height(to_global(objects.translation))

func look_at_cell(game_pos):
	var pos = world_data.get_world_pos(game_pos)
	look_at(pos, Vector3(0,1,0))