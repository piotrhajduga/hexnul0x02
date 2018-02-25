extends Spatial

signal moved (actor, from_pos)

var pathfinder

var game_position = Vector2() setget set_game_position

var path = PoolVector2Array()

var MOVEMENT_SPEED = 0.3
var msec_passed = 0.0

func _physics_process(delta):
	msec_passed += delta
	if msec_passed > MOVEMENT_SPEED:
		msec_passed = 0
		if path.size() > 0:
			set_game_position(path[0])
			path.remove(0)

func find_path(target_position):
	if pathfinder:
		path = pathfinder.get_path(game_position, target_position)
	else:
		set_game_position(target_position)

func set_game_position(target_position):
	var from_position = game_position
	game_position = target_position
	emit_signal("moved", self, from_position)