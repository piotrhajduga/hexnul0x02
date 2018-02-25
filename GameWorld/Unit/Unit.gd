extends Spatial

var game_position = Vector2()
var target_position = game_position

var path = PoolVector2Array()

func _process(delta):
	if path.size() > 0:
		game_position = path[-1]
		path.remove(-1)
	elif game_position != target_position:
		find_path()

func find_path():
	pass