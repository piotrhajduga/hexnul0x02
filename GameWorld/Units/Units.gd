extends Spatial

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)
export(NodePath) var pathfinder_node
onready var pathfinder = get_node(pathfinder_node)

var map = {}

signal unit_placed(unit, pos)
signal unit_moved(unit, from, to)

func place_unit(UnitType, pos):
	if not map.has(pos) and world_data.is_passable(pos):
		var unit = UnitType.instance()
		unit.world_data = world_data
		unit.pathfinder = pathfinder
		unit.game_position = pos
		map[pos] = unit
		unit.connect("moved", self, "_on_unit_moved")
		add_child(unit)
		emit_signal("unit_placed", unit, pos)
		select(unit)

func _on_unit_moved(unit, from_pos):
	map.erase(from_pos)
	map[unit.game_position] = unit
	emit_signal("unit_moved", unit, from_pos, unit.game_position)

func move_unit(unit, pos):
	unit.path = pathfinder.get_path(unit.game_position, pos)
	return unit.path.size() > 0

func select(pos):
	return map[pos] if map.has(pos) else null

func _on_GameCamera_moved(target_position, camera_y_angle):
	for unit in get_children():
		var delta = unit.translation - target_position
		if delta.length() <= 30:
			unit.show()
		else: unit.hide()