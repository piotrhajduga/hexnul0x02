extends Node

var SoftNoise = preload("res://terrain/softnoise.gd")

const NOISES_COUNT = 5
var noises_weight_sum = 0.0
var noises_scales = [0.02,0.06,0.18,0.35,0.49,0.73]
var noises_modifiers = []
var noise = null

const TERRAIN_HEIGHT_SCALE = 15.0
const xStep = 1.0
const zStep = sqrt(3.0) / 2.0

export(float,0,1) var water_height = 0.4
export(float,0,1) var sand_height = 0.401
export(float,0,1) var grass_height = 0.44
export(float,0,1) var stone_height = 0.57
export(float,0,1) var snow_height = 0.66

enum cell_type {WATER, SAND, GRASS, STONE, SNOW}

func _init():
	randomize()
	noise = SoftNoise.new(randi())
	for i in range(NOISES_COUNT):
		noises_modifiers.insert(i, Vector2(randf(),randf()))

func get_height(x, y):
	var sum = 0.0
	var sum_weight = 1.0
	var weight = 1.0
	for i in range(NOISES_COUNT):
		var scale = noises_scales[i]
		var probe = (Vector2(x,y) + noises_modifiers[i]) * noises_scales[i]
		var val = (noise.openSimplex2D(probe.x, probe.y) + 1.0) * 0.5
		val *= weight
		sum += val
		weight = val
		sum_weight += weight
	return sum / sum_weight

func get_terrain_mesh_height(x,y):
	var height = get_height(x,y)
	if height < water_height: height = water_height
	height -= water_height
	height /= 1.0 - water_height
	return height * height * TERRAIN_HEIGHT_SCALE

func get_game_coords(pos):
	var x = int(round(pos.x / (1.5 * xStep)))
	var zpos = pos.z
	if x % 2 != 0:
		zpos -= zStep / 2.0
	var y = int(round(zpos / (2.0 * zStep)))
	return Vector2(x,y)
	
func get_world_coords(x,y):
	var pos = Vector3()
	pos.x = floor(x) * 1.5 * xStep
	pos.z = floor(y) * 2.0 * zStep
	if int(x) % 2 != 0:
		pos.z += zStep
	return pos
	
func get_cell_type(height):
	if height>=snow_height: return SNOW
	elif height>=stone_height: return STONE
	elif height>=grass_height: return GRASS
	elif height>=sand_height: return SAND
	else: return WATER