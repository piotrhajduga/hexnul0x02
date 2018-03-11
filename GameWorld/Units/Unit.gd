extends Spatial

signal moved (actor, from_pos)

onready var game_space = get_node("/root/GameSpace")
var world_data
var pathfinder

var game_position = Vector2() setget set_game_position

var path = PoolVector2Array()

var MOVEMENT_SPEED = 0.02
var msec_passed = 0.0

const up = Vector3(0,1,0)

func _ready():
	set_world_position(world_data.get_world_pos(game_position))
	var neighbors = game_space.offset_neighbors(game_position)
	look_at_cell(neighbors[randi()%6])

func look_at_cell(game_pos):
	var pos = world_data.get_world_pos(game_pos)
	var height = world_data.get_terrain_mesh_height(pos)
	look_at(pos + up * height, up)

func next_step():
	if path.size() > 1:
		look_at_cell(path[1])
		if pathfinder.is_passable(path[1]):
			path.remove(0)

func _movement():
	if path.size() > 0:
		var delta = world_data.get_world_pos(path[0])-Vector3(1,0,1)*self.translation
		if delta.length() < MOVEMENT_SPEED:
			set_game_position(path[0])
			set_world_position(world_data.get_world_pos(game_position))
			next_step()
		elif pathfinder.is_passable(path[0]):
			self.translation += delta.normalized() * MOVEMENT_SPEED
			self.translation.y = world_data.get_terrain_mesh_height(self.translation)
		else:
			set_game_position(game_position)
			set_world_position(world_data.get_world_pos(game_position))
			path = []

func _physics_process(delta):
	_movement()
#	msec_passed += delta
#	if msec_passed > MOVEMENT_SPEED:
#		msec_passed = 0
#		if path.size() > 0:
#			set_game_position(path[0])
#			if path.size() > 1:
#				look_at_cell(path[1])
#			path.remove(0)

func set_world_position(target_position):
	self.translation = target_position
	self.translation.y = world_data.get_terrain_mesh_height(target_position)

func set_game_position(target_position):
	var from_position = game_position
	game_position = target_position
	emit_signal("moved", self, from_position)