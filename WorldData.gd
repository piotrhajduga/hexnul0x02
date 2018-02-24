extends Node

var SoftNoise = preload("res://GameWorld/softnoise.gd")

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

enum cell_type {WATER, SAND, GRASS, STONE, GRAVEL, SNOW}

const xStep = 1.0
const zStep = sqrt(3.0) / 2.0
const up = Vector3(0.0,1.0,0.0)

var astar = AStar.new()

func _ready():
	if game_seed == null:
		randomize()
	else:
		seed(game_seed.hash())
	noise = SoftNoise.new(game_seed.hash())
	for i in range(noises_scales.size()):
		noises_modifiers.insert(i, Vector2(randf(),randf()))
		
func add_cell(game_pos):
	var pos = get_world_pos(game_pos)
	var type = get_cell_type(pos)
	var id = astar.get_available_point_id()
	astar.add_point(id, pos, 1+get_height(pos))
	for xi in range(-1,1):
		for yi in range(-1,1):
			if xi == 0 and yi == 0:
				continue
			var neighbor = get_world_pos(game_pos + Vector2(xi, yi))
			if ![STONE,WATER].has(get_cell_type(neighbor)):
				astar.connect_points(id, astar.get_closest_point(neighbor))

func get_game_pos(pos):
	var x = int(round(pos.x / (1.5 * xStep)))
	var zpos = pos.z
	if x % 2 != 0:
		zpos -= zStep / 2.0
	var y = int(round(zpos / (2.0 * zStep)))
	return Vector2(x,y)
	
func get_world_pos(game_pos):
	var pos = Vector3()
	pos.x = floor(game_pos.x) * 1.5 * xStep
	pos.z = floor(game_pos.y) * 2.0 * zStep
	if int(game_pos.x) % 2 != 0:
		pos.z += zStep
	return pos

func get_height(pos):
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
	return sum / sum_weight

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
	if acos(up.dot(get_normal(pos))) > PI/8:
		return STONE
	elif height>=gravel_height: return GRAVEL
	elif height>=grass_height: return GRASS
	elif height>=sand_height: return SAND
	else: return WATER