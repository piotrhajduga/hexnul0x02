extends Node

#type GamePos - offset coords Vector2[int]
#type WorldPos - world coords Vector3

var SoftNoise = preload("res://GameWorld/softnoise.gd")

export var WORLD_RADIUS = 128
export var WORLD_RADIUS_FEATHER = 24
export var TERRAIN_HEIGHT_SCALE = 15.0
export var stone_min_angle = PI/8.0

var noises_weight_sum = 0.0
export var noises_scales = PoolRealArray([0.006,0.023,0.124,0.34,0.19,0.53])
var noises_modifiers = PoolVector2Array()
var noise = null

export(String) var game_seed = null

export(float,0,1) var water_height = 0.41
export(float,0,1) var sand_height = 0.411
export(float,0,1) var grass_height = 0.43
export(float,0,1) var gravel_height = 0.61
export(float,0,1) var snow_height = 0.67

onready var game_space = get_node("/root/GameSpace")

enum cell_type {WATER, SAND, GRASS, STONE, GRAVEL, SNOW}

const xStep = 1.0
const zStep = sqrt(3.0) / 2.0
const up = Vector3(0.0,1.0,0.0)

func _ready():
	if game_seed == null:
		randomize()
	else:
		seed(game_seed.hash())
	noise = SoftNoise.new(game_seed.hash())
	for i in range(noises_scales.size()):
		noises_modifiers.insert(i, Vector2(randf(),randf()))

func get_cells_in_radius(pos, radius):
	return game_space.offset_range(pos, radius)
#	var points = []
#	for x in range(-radius,radius+1):
#		for y in range(2*radius+1-int(abs(x))):
#			points.append(Vector2(
#				int(pos.x) + x,
#				int(pos.y) + y - radius + floor(abs(x)/2)+(int(abs(pos.x))%2)*(int(abs(x))%2)
#			))
#	return points

func get_game_pos(pos):
	return game_space.world_to_offset(pos)
#	var x = int(round(pos.x / (1.5 * xStep)))
#	var zpos = pos.z
#	if x % 2 != 0:
#		zpos -= zStep / 2.0
#	var y = int(round(zpos / (2.0 * zStep)))
#	return Vector2(x,y)

func is_passable(game_pos):
	var impassable = [
		SNOW,
		STONE,
		WATER
	]
	return not impassable.has(get_cell_type(get_world_pos(game_pos)))
	
func get_world_pos(game_pos):
	return game_space.offset_to_world(game_pos)
#	var pos = Vector3()
#	pos.x = floor(game_pos.x) * 1.5 * xStep
#	pos.z = floor(game_pos.y) * 2.0 * zStep
#	if int(game_pos.x) % 2 != 0:
#		pos.z += zStep
#	return pos

func get_height(pos):
	var radius = pos.length()
	if radius > WORLD_RADIUS: return 0.0
	var sum = 0.0
	var sum_weight = 1.0
	var weight = 1.0
	for i in range(noises_scales.size()):
		var scale = noises_scales[i]
		var probe = (Vector2(pos.x,pos.z) + noises_modifiers[i]) * noises_scales[i]
		var val = (noise.openSimplex2D(probe.x, probe.y) + 1.0) * 0.5
		val *= weight
		sum += val
		weight = val
		sum_weight += weight
	return ((WORLD_RADIUS - max(radius,WORLD_RADIUS-WORLD_RADIUS_FEATHER)) / WORLD_RADIUS_FEATHER) * sum / sum_weight

func get_normal(pos):
	var delta = Vector3(0.001,0.0,0.0)
	var p0 = pos + delta
	p0.y = get_terrain_mesh_height(p0)
	var p1 = pos + delta.rotated(up, PI*2/3)
	p1.y = get_terrain_mesh_height(p1)
	var p2 = pos + delta.rotated(up, PI*4/3)
	p2.y = get_terrain_mesh_height(p2)
	return (p1-p0).cross(p2-p0).normalized()

func get_terrain_mesh_height(pos):
	var height = get_height(pos)
	if height < water_height: height = water_height
	height -= water_height
	height /= 1.0 - water_height
	return height * height * TERRAIN_HEIGHT_SCALE

func get_cell_type(pos):
	var height = get_height(pos)
	if height>=snow_height: return SNOW
	if acos(up.dot(get_normal(pos))) > stone_min_angle:
		return STONE
	elif height>=gravel_height: return GRAVEL
	elif height>=grass_height: return GRASS
	elif height>=sand_height: return SAND
	else: return WATER