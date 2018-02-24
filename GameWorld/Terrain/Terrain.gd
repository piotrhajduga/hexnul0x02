extends Spatial

var Cell = preload("Cell.gd")

export(int) var radius = 32

onready var collision = get_node("Area/CollisionShape")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

export(Material) var cell_material = preload("TerrainCell.material")

func _ready():
	cell_material.set_shader_param("terrain_height_scale", world_data.TERRAIN_HEIGHT_SCALE)
	cell_material.set_shader_param("stone_min_angle", world_data.stone_min_angle)
	cell_material.set_shader_param("snow_height", world_data.snow_height)
	cell_material.set_shader_param("gravel_height", world_data.gravel_height)
	cell_material.set_shader_param("grass_height", world_data.grass_height)
	cell_material.set_shader_param("sand_height", world_data.sand_height)
	cell_material.set_shader_param("water_height", world_data.water_height)
	
	var points = PoolVector3Array()
	for x in range(-radius,radius):
		var yfrom = -radius+abs(x)/2
		var yto = radius-ceil(abs(x)/2.0)
		for y in range(yfrom, yto):
			add_cell(x, y)
			points.append(get_world_point(x,y))
			points.append(get_world_point(x,y+1))
			points.append(get_world_point(x+1,y+1))
			points.append(get_world_point(x+1,y+1))
			points.append(get_world_point(x+1,y))
			points.append(get_world_point(x,y))
	collision.shape = ConcavePolygonShape.new()
	collision.shape.set_faces(points)
	collision.disabled = false

func add_cell(x,y):
	var game_pos = Vector2(x,y)
	var world_pos = world_data.get_world_pos(game_pos)
	world_data.add_cell(game_pos)
	var cell = Cell.new(world_data, cell_material)
	add_child(cell)
	cell.global_translate(world_pos)
	cell.update_shape()
	cell.scale = Vector3(1.002,1.0,1.002)

func get_world_point(x,y):
	var pt = world_data.get_world_pos(Vector2(x,y))
	pt.y = world_data.get_terrain_mesh_height(pt)
	return pt