extends Node

var SoftNoise = preload("res://GameWorld/softnoise.gd")

var Unit = preload("res://GameWorld/Unit/Unit.tscn")

const TERRAIN_HEIGHT_SCALE = 15.0

var noises_weight_sum = 0.0
export var noises_scales = [0.006,0.023,0.164,0.41,0.26,0.73]
var noises_modifiers = []
var noise = null

export(String) var game_seed = ""

export(float,0,1) var water_height = 0.42
export(float,0,1) var sand_height = 0.421
export(float,0,1) var grass_height = 0.45
export(float,0,1) var stone_height = 0.61
export(float,0,1) var snow_height = 0.68

enum cell_type {WATER, SAND, GRASS, STONE, SNOW}

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

func get_terrain_mesh_height(pos):
	var height = get_height(pos)
	if height < water_height: height = water_height
	height -= water_height
	height /= 1.0 - water_height
	return height * height * TERRAIN_HEIGHT_SCALE
	
func get_cell_type(height):
	if height>=snow_height: return SNOW
	elif height>=stone_height: return STONE
	elif height>=grass_height: return GRASS
	elif height>=sand_height: return SAND
	else: return WATER

func create_unit(pos):
	var unit = Unit.instance()
	unit.translation = pos
	unit.translation.y = get_terrain_mesh_height(pos)
	self.add_child(unit)