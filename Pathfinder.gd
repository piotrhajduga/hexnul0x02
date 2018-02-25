extends Node

var astar = AStar.new()

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

export(int) var radius = 32;

func add_cell(game_pos):
	var pos = world_data.get_world_pos(game_pos)
	var type = world_data.get_cell_type(pos)
	var id = astar.get_available_point_id()
	astar.add_point(id, pos, ceil(10*get_height(pos)))

func connect_cell(game_pos):
	var id = astar.get_closest_point(world_data.get_world_pos(game_pos))
	for xi in range(-1,1):
		for yi in range(-1,1):
			if xi == 0 and yi == 0:
				continue
			var neighbor = world_data.get_world_pos(game_pos + Vector2(xi, yi))
			if ![world_data.STONE,world_data.WATER].has(get_cell_type(neighbor)):
				astar.connect_points(id, astar.get_closest_point(neighbor))

func update():
	astar.clear()
	for x in range(-radius-1,radius+1):
		var yfrom = -radius+abs(x)/2
		var yto = radius-ceil(abs(x)/2.0)
		for y in range(yfrom-1, yto+1):
			add_cell(Vector2(x,y))
	for x in range(-radius,radius):
		var yfrom = -radius+abs(x)/2
		var yto = radius-ceil(abs(x)/2.0)
		for y in range(yfrom, yto):
			connect_cell(Vector2(x,y))