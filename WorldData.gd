extends Node

var SoftNoise = preload("res://GameWorld/softnoise.gd")

onready var game_world = get_parent()

const TERRAIN_HEIGHT_SCALE = 15.0

var noises_weight_sum = 0.0
export var noises_scales = [0.006,0.023,0.164,0.41,0.26,0.53]
var noises_modifiers = []
var noise = null

export(String) var game_seed = ""

export(float,0,1) var water_height = 0.42
export(float,0,1) var sand_height = 0.421
export(float,0,1) var grass_height = 0.45
export(float,0,1) var gravel_height = 0.61
export(float,0,1) var snow_height = 0.67

enum cell_type {WATER, SAND, GRASS, STONE, GRAVEL, SNOW}

func _init():
	if game_seed == "": 
		randomize()
	else:
		seed(game_seed)
	noise = SoftNoise.new(randi())
	for i in range(noises_scales.size()):
		noises_modifiers.insert(i, Vector2(randf(),randf()))

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
	var d2d = 0.01
	var p0 = pos + Vector3(d2d,0.0,-d2d)
	p0.y = get_terrain_mesh_height(p0)
	var p1 = pos + Vector3(-d2d,0.0,0.0)
	p1.y = get_terrain_mesh_height(p1)
	var p2 = pos + Vector3(0.0,0.0,d2d)
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
	if acos(Vector3(0.0,1.0,0.0).dot(get_normal(pos))) > PI/10:
		return STONE
	elif height>=gravel_height: return GRAVEL
	elif height>=grass_height: return GRASS
	elif height>=sand_height: return SAND
	else: return WATER