extends Spatial

const xStep = 1.0
const zStep = sqrt(3.0) / 2.0

export(Material) var water = null
export(float,0,1) var water_height = 0.36
export(Material) var sand = null
export(float,0,1) var sand_height = 0.37
export(Material) var grass = null
export(float,0,1) var grass_height = 0.41
export(Material) var stone = null
export(float,0,1) var stone_height = 0.61
export(Material) var snow = null
export(float,0,1) var snow_height = 0.69

export(int) var cols = 60
export(int) var rows = 40

var Cell = preload("res://Cell.gd")

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

func create_cell(coords):
	return Cell.new(coords, water_height)
	
func get_material(height):
	if height>=snow_height: return snow
	elif height>=stone_height: return stone
	elif height>=grass_height: return grass
	elif height>=sand_height: return sand
	else: return water

onready var globals = get_node("/root/global")

func _ready():
	if !is_visible_in_tree():
		return
	var cell
	var height
	
	for x in range(-cols/2,cols/2+1):
		for y in range(-rows/2,rows/2+1):
			var world_coords = get_world_coords(x,y)
			cell = create_cell(world_coords)
			
			height = globals.get_height(world_coords.x,world_coords.z)
			
			cell.scale = Vector3(1.01,1.0,1.01)
			
			add_child(cell)
			
			cell.global_translate(world_coords)
			cell.set_surface_material(0, get_material(height))