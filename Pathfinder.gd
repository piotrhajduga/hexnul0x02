extends Node

class HexAStar extends AStar:
	func _compute_cost(from_id, to_id):
		var from_pos = self.get_point_position(from_id)
		var to_pos = self.get_point_position(to_id)
		return 1+(to_pos-from_pos).length()
		
	func _estimate_cost(from_id, to_id):
		return 1 + (get_point_weight_scale(to_id) - get_point_weight_scale(from_id))

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

onready var astar = HexAStar.new()

export(Vector2) var game_pos = Vector2()
export(int) var radius = 5

func add_cell(cell_pos):
	var pos = world_data.get_world_pos(cell_pos)
	var type = world_data.get_cell_type(pos)
	var id = astar.get_available_point_id()
	astar.add_point(id, pos, 1+15*pow(world_data.get_height(pos),2))

func connect_cell(cell_pos):
	if world_data.is_passable(cell_pos):
		var id = astar.get_closest_point(world_data.get_world_pos(cell_pos))
		for neighbor in world_data.get_cells_in_radius(cell_pos,1):
			if neighbor!=cell_pos and world_data.is_passable(neighbor):
				astar.connect_points(id, astar.get_closest_point(world_data.get_world_pos(neighbor)), false)

func cell_type(game_pos):
	return world_data.get_cell_type(world_data.get_world_pos(game_pos))

func get_path(from, to):
	var path = []
	if world_data.get_cells_in_radius(from,radius).has(to):
		var idfrom = astar.get_closest_point(world_data.get_world_pos(from))
		var idto = astar.get_closest_point(world_data.get_world_pos(to))
		var aspath = astar.get_point_path(idfrom, idto)
		if aspath.size() <= radius+1:
			for point in aspath:
				path.append(world_data.get_game_pos(point))
	return path

func _ready():
	update()

func update():
	astar.clear()
	for cell_pos in world_data.get_cells_in_radius(game_pos,radius):
		add_cell(cell_pos)
	for cell_pos in world_data.get_cells_in_radius(game_pos,radius-1):
		connect_cell(cell_pos)

func is_passable(cell_pos):
	return get_path(game_pos, cell_pos).size() > 0