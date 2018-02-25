extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.gd")

export(int) var radius = 32

onready var collision = get_node("Area/CollisionShape")

var world_data = null

export(Material) var cell_material = preload("TerrainCell.material")

export(Vector2) var center = Vector2()
var cells = {}

func _ready():
	cell_material.set_shader_param("terrain_height_scale", world_data.TERRAIN_HEIGHT_SCALE)
	cell_material.set_shader_param("stone_min_angle", world_data.stone_min_angle)
	cell_material.set_shader_param("snow_height", world_data.snow_height)
	cell_material.set_shader_param("gravel_height", world_data.gravel_height)
	cell_material.set_shader_param("grass_height", world_data.grass_height)
	cell_material.set_shader_param("sand_height", world_data.sand_height)
	cell_material.set_shader_param("water_height", world_data.water_height)
	update()

func update():
	var visible_cells = world_data.get_cells_in_radius(center, radius)

	var points = PoolVector3Array()

	for game_pos in visible_cells:
		if not cells.has(game_pos):
			add_cell(game_pos)
		points.append_array(create_collision_hex(game_pos))

	collision.shape = ConcavePolygonShape.new()
	collision.shape.set_faces(points)
	collision.disabled = false

func create_collision_hex(game_pos):
	var x = game_pos.x
	var y = game_pos.y
	var points = PoolVector3Array()
	points.append(get_world_point(x,y))
	points.append(get_world_point(x,y+1))
	points.append(get_world_point(x+1,y+1))
	points.append(get_world_point(x+1,y+1))
	points.append(get_world_point(x+1,y))
	points.append(get_world_point(x,y))
	return points

func add_cell(game_pos):
	var world_pos = world_data.get_world_pos(game_pos)
	cells[game_pos] = Cell.new(world_data, cell_material)
	add_child(cells[game_pos])
	cells[game_pos].global_translate(world_pos)
	cells[game_pos].update_shape()
	cells[game_pos].scale = Vector3(1.002,1.0,1.002)

func get_world_point(x, y):
	var pt = world_data.get_world_pos(Vector2(x,y))
	pt.y = world_data.get_terrain_mesh_height(pt)
	return pt
