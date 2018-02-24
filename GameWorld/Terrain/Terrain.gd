extends Spatial

var Cell = preload("Cell.gd")

export(int) var cols = 60
export(int) var rows = 40

onready var game_world = get_parent()
onready var world_data = game_world.get_node("WorldData")

export(Material) var cell_material = preload("TerrainCell.material")

func _ready():
	cell_material.set_shader_param("terrain_height_scale", world_data.TERRAIN_HEIGHT_SCALE)
	cell_material.set_shader_param("stone_min_angle", world_data.stone_min_angle)
	cell_material.set_shader_param("snow_height", world_data.snow_height)
	cell_material.set_shader_param("gravel_height", world_data.gravel_height)
	cell_material.set_shader_param("grass_height", world_data.grass_height)
	cell_material.set_shader_param("sand_height", world_data.sand_height)
	cell_material.set_shader_param("water_height", world_data.water_height)
	
	for x in range((-cols/2),cols/2):
		for y in range((-rows/2),rows/2):
			var game_pos = Vector2(x,y)
			var world_pos = world_data.get_world_pos(game_pos)
			var cell_type = world_data.get_cell_type(world_pos)
			var cell = Cell.new(world_data, cell_material)
			add_child(cell)
			cell.global_translate(world_pos)
			cell.update_shape()
			cell.scale = Vector3(1.002,1.0,1.002)
			world_data.add_cell(game_pos, cell_type)