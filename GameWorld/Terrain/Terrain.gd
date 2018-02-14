extends Spatial

var Cell = preload("Cell.gd")

export(int) var cols = 60
export(int) var rows = 40

onready var globals = get_node("/root/GameWorldGlobals")
onready var game_world = get_parent()
onready var world_data = game_world.get_node("WorldData")

export(Material) var water = preload("Water.tres.material")
export(Material) var sand = preload("Sand.tres.material")
export(Material) var grass = preload("Grass.tres.material")
export(Material) var gravel = preload("Gravel.tres")
export(Material) var stone = preload("Stone.tres.material")
export(Material) var snow = preload("Snow.tres.material")

func get_material(cell_type):
	match cell_type:
		world_data.SNOW: return snow
		world_data.STONE: return stone
		world_data.GRAVEL: return gravel
		world_data.GRASS: return grass
		world_data.SAND: return sand
		_: return water
	
func get_world_point(x,y):
	var pt = globals.get_world_coords(x,y)
	pt.y = world_data.get_terrain_mesh_height(pt)
	return pt

func _ready():
	for x in range((-cols/2),cols/2):
		for y in range((-rows/2),rows/2):
			var world_coords = globals.get_world_coords(x,y)
			var cell_type = world_data.get_cell_type(world_coords)
			var cell = Cell.new(world_data, get_material(cell_type))
			cell.scale = Vector3(1.005,1.0,1.005)
			add_child(cell)
			cell.global_translate(world_coords)
			cell.update_shape()
