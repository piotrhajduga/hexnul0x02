extends Spatial

signal moved (unit, from_pos)

onready var game_space = get_node("/root/GameSpace")
var world_data
var pathfinder
onready var units = get_parent()

var game_position = Vector2() setget set_game_position

var path = []

var MOVEMENT_SPEED = 0.02
var msec_passed = 0.0

const up = Vector3(0,1,0)

func _ready():
	self.name = "Unit"
	set_world_position(world_data.get_world_pos(game_position))
	var neighbors = game_space.offset_neighbors(game_position)
	look_at_cell(neighbors[randi()%6])

func look_at_cell(game_pos):
	var pos = world_data.get_world_pos(game_pos)
	var height = world_data.get_terrain_mesh_height(pos)
	look_at(pos + up * height, up)

func _movement():
	var delta = world_data.get_world_pos(game_position)-Vector3(1,0,1)*self.translation
	if delta.length() > MOVEMENT_SPEED:
		self.translation += delta.normalized() * MOVEMENT_SPEED
		self.translation.y = world_data.get_terrain_mesh_height(self.translation)
	elif path.size() > 0:
		if path.front() == game_position or pathfinder.is_passable(path.front()):
			look_at_cell(path.front())
			set_game_position(path.front())
			path.pop_front()
		else:
			var new_path = pathfinder.get_path(game_position, path.back())
			self.path = new_path

func _physics_process(delta):
	_movement()

func set_world_position(target_position):
	self.translation = target_position
	self.translation.y = world_data.get_terrain_mesh_height(target_position)

func set_game_position(target_position):
	var from_position = game_position
	game_position = target_position
	emit_signal("moved", self, from_position)