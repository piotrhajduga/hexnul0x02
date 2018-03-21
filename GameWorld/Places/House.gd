extends Spatial

onready var game_space = get_node("/root/GameSpace")

var world_data
var game_position = Vector2()

func _ready():
	self.name = "House"
	self.translation = world_data.get_world_pos(game_position)
	$WoodPile.count = 0
	var neighbors = game_space.offset_neighbors(game_position)
	look_at_cell(neighbors[randi()%6])
	for object in get_children():
		object.translation.y = world_data.get_terrain_mesh_height(to_global(object.translation))

func look_at_cell(game_pos):
	var pos = world_data.get_world_pos(game_pos)
	look_at(pos, Vector3(0,1,0))

var TIME_TO_HARVEST = 1
var time_to_harvest = TIME_TO_HARVEST
func _process(delta):
	if time_to_harvest - delta <= 0:
		self.time_to_harvest = TIME_TO_HARVEST
		harvest()
	else:
		self.time_to_harvest -= delta

func harvest():
	for offset in game_space.offset_neighbors(game_position):
		if world_data.is_forest(game_space.offset_to_world(offset)):
			$WoodPile.inc()