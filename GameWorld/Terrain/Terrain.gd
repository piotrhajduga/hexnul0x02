extends Spatial

var Cell = preload("Cell.gd")

export(int) var cols = 60
export(int) var rows = 40

onready var game_world = get_parent()
onready var world_data = game_world.get_node("WorldData")

export(Material) var cell_material = preload("TerrainCell.material")

func _ready():
	for x in range((-cols/2),cols/2):
		for y in range((-rows/2),rows/2):
			var game_pos = Vector2(x,y)
			var world_pos = world_data.get_world_pos(game_pos)
			var cell_type = world_data.get_cell_type(world_pos)
			var cell = Cell.new(world_data, cell_material)
			cell.scale = Vector3(1.002,1.0,1.002)
			add_child(cell)
			cell.global_translate(world_pos)
			cell.update_shape()
			world_data.add_cell(game_pos, cell_type)