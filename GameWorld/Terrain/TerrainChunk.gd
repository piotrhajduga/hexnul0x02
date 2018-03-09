extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.tscn")
var ForestCell = preload("res://GameWorld/Terrain/ForestCell.tscn")

export(int) var radius = 4

onready var game_space = get_node("/root/GameSpace")
onready var collision = get_node("Area/CollisionShape")

var world_data = null

export(Material) var cell_material = preload("TerrainCell.material")

export(Vector2) var center = Vector2()
var cells = {}

func _ready():
	update()

func cell_range(offset,N):
	var cube = game_space.offset_to_cube(offset)
	var results = []
	for dx in range(-N, N+1):
		for dy in range(-N, N+1):
			var dz = -dx-dy
			results.append(game_space.cube_to_offset(Vector3(dx, dy, dz) + cube))
	return results

func update():
	for game_pos in cell_range(center, int(radius)):
		if not cells.has(game_pos):
			add_cell(game_pos)
	var points = PoolVector3Array()
	for game_pos in cell_range(center, int(radius)+1):
		points.append_array(create_collision_hex(game_pos))
	collision.shape = ConcavePolygonShape.new()
	collision.shape.set_faces(points)
	collision.disabled = false

func _on_camera_move(cam_game_pos):
	for cell in get_children():
		var delta = cell.translation - game_space.offset_to_world(cam_game_pos)
		if delta.length() <= 30:
			cell.show()
		else: cell.hide()

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
	cells[game_pos] = Cell.instance()
	cells[game_pos].world_data = world_data
	cells[game_pos].material = cell_material
	add_child(cells[game_pos])
	cells[game_pos].global_translate(world_pos)
	cells[game_pos].update_shape()
	if world_data.is_forest(world_pos):
		var forest = ForestCell.instance()
		forest.world_data = world_data
		forest.rotation = Vector3(0,randf(),0)
		cells[game_pos].add_child(forest)
	cells[game_pos].scale = Vector3(1.002,1.0,1.002)

func get_world_point(x, y):
	var pt = world_data.get_world_pos(Vector2(x,y))
	pt.y = world_data.get_terrain_mesh_height(pt)
	return pt
