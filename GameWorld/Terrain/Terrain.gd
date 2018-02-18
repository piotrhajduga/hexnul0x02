extends Spatial

var Cell = preload("Cell.gd")

export(int) var cols = 60
export(int) var rows = 40

onready var game_world = get_parent()
onready var world_data = game_world.get_node("WorldData")

export(Material) var water = preload("Water.tres.material")
export(Material) var sand = preload("Sand.tres.material")
export(Material) var grass = preload("Grass.tres.material")
export(Material) var gravel = preload("Gravel.tres.material")
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

func _ready():
	for x in range((-cols/2),cols/2):
		for y in range((-rows/2),rows/2):
			var game_pos = Vector2(x,y)
			var world_pos = world_data.get_world_pos(game_pos)
			var cell_type = world_data.get_cell_type(world_pos)
			var cell = Cell.new(world_data, get_material(cell_type))
			cell.scale = Vector3(1.002,1.0,1.002)
			add_child(cell)
			cell.global_translate(world_pos)
			cell.update_shape()
			world_data.add_cell(game_pos, cell_type)