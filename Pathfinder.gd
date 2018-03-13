extends Node

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

export(NodePath) var game_logic_node
onready var game_logic = get_node(game_logic_node)

onready var game_space = get_node("/root/GameSpace")

func _ready():
	pass

func _g_cost(from_cube, to_cube):
	var from = game_space.offset_to_world(game_space.cube_to_offset(from_cube))
	var to = game_space.offset_to_world(game_space.cube_to_offset(to_cube))
	return world_data.get_height(to) - world_data.get_height(from)
	
func _h_cost(from, to):
	return game_space.cube_distance(from, to)

func _is_passable(pos):
	return is_passable(game_space.cube_to_offset(pos))

func get_path(from_off, to_off):
	var from = game_space.offset_to_cube(from_off)
	var to = game_space.offset_to_cube(to_off)
	var closedSet = []
	var openSet = [from]
	var cameFrom = {}
	var g_score = { from: 0 }
	var f_score = { from: _h_cost(from, to) }
	while not openSet.empty():
		var cur = openSet[0]
		for ios in range(1, openSet.size()):
			if f_score.has(openSet[ios]) and f_score[openSet[ios]] < f_score[cur]:
				cur = openSet[ios]
		if cur == to:
			return reconstruct_path(cameFrom, cur)
		openSet.erase(cur)
		if not closedSet.has(cur):
			closedSet.append(cur)
		for neighbor in game_space.cube_neighbors(cur):
			if not _is_passable(neighbor) or closedSet.has(neighbor):
				continue
			if not openSet.has(neighbor):
				openSet.append(neighbor)
			var tgscore = g_score[cur] + _g_cost(cur, neighbor)
			if g_score.has(neighbor) and tgscore >= g_score[neighbor]:
				continue
			cameFrom[neighbor] = cur
			g_score[neighbor] = tgscore
			f_score[neighbor] = tgscore + _h_cost(neighbor, to)
	return []

func reconstruct_path(cameFrom, current):
	var path = [game_space.cube_to_offset(current)]
	while cameFrom.keys().has(current):
		current = cameFrom[current]
		path.push_front(game_space.cube_to_offset(current))
	return path

func is_passable(cell_pos):
	return (
		world_data.is_passable(cell_pos)
		and (not game_logic.units.map.has(cell_pos) and not game_logic.places.map.has(cell_pos))
	)
