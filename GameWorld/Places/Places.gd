extends Spatial

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

var map = {}

signal place_placed(place, pos)

func place_place(PlaceType, pos):
	if not map.has(pos) and world_data.is_passable(pos):
		var place = PlaceType.instance()
		place.world_data = world_data
		place.game_position = pos
		map[pos] = place
		add_child(place)
		emit_signal("place_placed", place, pos)

func select(pos):
	return map[pos] if map.has(pos) else null

func _on_GameCamera_moved(target_position, camera_y_angle):
	for place in get_children():
		var delta = place.translation - target_position
		if delta.length() <= 30:
			place.show()
		else: place.hide()