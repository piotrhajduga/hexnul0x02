extends Node

var SoftNoise = preload("res://softnoise.gd")

const NOISES_COUNT = 5
var noises_weight_sum = 0.0
var noises_scales = [0.02,0.06,0.23,0.35,0.49,0.73]
var noises_modifiers = []
var noise = null

const TERRAIN_HEIGHT_SCALE = 15.0

var cols = 60
var rows = 40

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
	return height * height * TERRAIN_HEIGHT_SCALE