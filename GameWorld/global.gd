extends Node

const TERRAIN_HEIGHT_SCALE = 15.0
const xStep = 1.0
const zStep = sqrt(3.0) / 2.0

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