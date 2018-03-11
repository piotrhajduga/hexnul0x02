extends Node

const xStep = 1.0
const zStep = xStep * sqrt(3.0) / 2.0

var cube_directions = [
	Vector3(1, -1, 0), Vector3(1, 0, -1), Vector3(0, 1, -1),
	Vector3(-1, 1, 0), Vector3(-1, 0, 1), Vector3(0, -1, 1)
]

func world_to_offset(pos):
	var x = int(round(pos.x / (1.5 * xStep)))
	var zpos = pos.z
	if x % 2 != 0:
		zpos -= zStep / 2.0
	var y = int(round(zpos / (2.0 * zStep)))
	return Vector2(x,y)

func offset_to_world(offset):
	var x = floor(offset.x) * 1.5 * xStep
	var z = floor(offset.y) * 2.0 * zStep
	if int(offset.x) & 1 != 0:
		z += zStep
	return Vector3(x,0,z)

func cube_to_offset(cube):
	var col = int(cube.x)
	var row = int(cube.z + (cube.x - (int(cube.x) & 1)) / 2)
	return Vector2(col,row)
	
func offset_to_cube(offset):
	var x = offset.x
	var z = offset.y - (offset.x - (int(offset.x) & 1)) / 2
	var y = - x - z
	return Vector3(x,y,z)

func cube_neighbors(cube):
	var results = []
	for c2 in cube_directions:
		results.append(cube + c2)
	return results

func offset_neighbors(offset):
	var results = []
	var cube = offset_to_cube(offset)
	for c2 in cube_directions:
		results.append(cube_to_offset(cube + c2))
	return results

func cube_direction(dir):
	return cube_directions(dir)
	
func cube_distance(a, b):
	return (abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)) / 2

#func lerp(a, b, t): # for floats
#    return a + (b - a) * t

func cube_lerp(a, b, t): # return cube
	return Vector3(
		lerp(a.x, b.x, t), 
		lerp(a.y, b.y, t),
		lerp(a.z, b.z, t)
	)

func cube_line(a, b):
	var N = cube_distance(a, b)
	var results = []
	for i in range(0, N+1):
		results.append(cube_round(cube_lerp(a, b, 1.0/N * i)))
	return results

func cube_range(cube, N):
	var results = []
	for dx in range(-N, N+1):
	    for dy in range(max(-N, -dx-N), min(N, -dx+N)+1):
	        var dz = -dx-dy
	        results.append(Vector3(dx, dy, dz) + cube)
	return results

func offset_range(offset, N):
	var results = []
	var cube = offset_to_cube(offset)
	for dx in range(-N, N+1):
	    for dy in range(max(-N, -dx-N), min(N, -dx+N)+1):
	        var dz = -dx-dy
	        results.append(cube_to_offset(Vector3(dx, dy, dz) + cube))
	return results