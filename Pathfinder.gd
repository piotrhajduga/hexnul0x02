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

export(int) var radius = 100;

func add_cell(game_pos):
	var pos = world_data.get_world_pos(game_pos)
	var type = world_data.get_cell_type(pos)
	var id = astar.get_available_point_id()
	astar.add_point(id, pos, 1+pow(world_data.get_height(pos),2))

func connect_cell(game_pos):
	if is_impassable(game_pos): return
	var id = astar.get_closest_point(world_data.get_world_pos(game_pos))
	for neighbor in world_data.get_cells_in_radius(game_pos,1):
		if is_impassable(neighbor) or neighbor==game_pos:
			continue
		astar.connect_points(id, astar.get_closest_point(world_data.get_world_pos(neighbor)), true)

func cell_type(game_pos):
	return world_data.get_cell_type(world_data.get_world_pos(game_pos))

func is_impassable(game_pos):
	var impassable = [
		world_data.SNOW,
		world_data.STONE,
		world_data.WATER
	]
	return impassable.has(cell_type(game_pos))

func get_path(from, to):
	var path = PoolVector2Array()
	var idfrom = astar.get_closest_point(world_data.get_world_pos(from))
	var idto = astar.get_closest_point(world_data.get_world_pos(to))
	var aspath = astar.get_point_path(idfrom, idto)
	for point in aspath:
		path.append(world_data.get_game_pos(point))
	return path

func _ready():
	astar.clear()
	for game_pos in world_data.get_cells_in_radius(Vector2(),radius):
		add_cell(game_pos)
	for game_pos in world_data.get_cells_in_radius(Vector2(),radius-1):
		connect_cell(game_pos)