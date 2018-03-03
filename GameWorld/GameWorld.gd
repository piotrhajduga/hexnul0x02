extends Spatial

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)
export(NodePath) var game_data_node
onready var game_data = get_node(game_data_node)

onready var pathfinder = $Selection.get_node("Pathfinder")

signal wagon(game_pos)
signal select(game_pos)
signal move(game_pos)

var mouse_pos = Vector2()
var selected = Vector2()

enum {MODE_IDLE,MODE_SELECT,MODE_WAGON,MODE_MOVE}
var mode = MODE_IDLE

func _ready():
	$GameCamera.target_position = Vector3()
	$Hover.show()
	mode = MODE_SELECT

func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)
		"InputEventKey": handle_keypress(event)

func handle_keypress(event):
	match event.scancode:
		KEY_W: _on_Units_mode_wagon()
		KEY_M: _on_Move_pressed()
		KEY_S: _on_Select_pressed()
		KEY_ESCAPE: mode = MODE_IDLE
	set_hover(get_cell_on_hover())

func handle_mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP:
			$GameCamera.move_camera($GameCamera.CAM_LO)
			$Hover.hide()
		BUTTON_WHEEL_DOWN:
			$GameCamera.move_camera($GameCamera.CAM_HI)
			$Hover.hide()
		BUTTON_LEFT:
			if !event.is_pressed(): use_tool()
	
func use_tool():
	match mode:
		MODE_WAGON: emit_signal("wagon", selected)
		MODE_SELECT: emit_signal("select", selected)
		MODE_MOVE: emit_signal("move", selected)
	mode = MODE_SELECT
	set_hover(selected)
	
func handle_mouse_motion(event):
	if event.button_mask & BUTTON_MASK_RIGHT:
		var relative = event.relative
		$GameCamera.move(relative)
		set_hover(null)
	elif event.button_mask & BUTTON_MASK_MIDDLE:
		set_hover(null)
		if event.relative.x > 0:
			$GameCamera.move_camera($GameCamera.CAM_TURN_LEFT)
		else:
			$GameCamera.move_camera($GameCamera.CAM_TURN_RIGHT)
	elif mode != MODE_IDLE:
		selected = get_cell_on_hover()
		set_hover(selected)

func set_hover(game_pos):
	mouse_pos = get_viewport().get_mouse_position()
	if game_pos != null and mode != MODE_IDLE:
		$Hover.translation = world_data.get_world_pos(game_pos)
		match(mode):
			MODE_MOVE:
				if pathfinder.is_passable(game_pos):
					$Hover.state = $Hover.STATE_MOVE_PASSABLE 
				else: $Hover.state = $Hover.STATE_MOVE_IMPASSABLE
			MODE_WAGON:
				if world_data.is_passable(game_pos):
					$Hover.state = $Hover.STATE_PLACE_UNIT
				else: $Hover.state = $Hover.STATE_MOVE_IMPASSABLE
			MODE_SELECT:
				$Hover.state = $Hover.STATE_HOVER
		$Hover.update()
		$Hover.show()
	else:
		$Hover.hide()

var ray_length = 100
func get_cell_on_hover():
	var pos2d = null
	var from = $GameCamera.project_ray_origin(mouse_pos)
	var to = from + $GameCamera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if result.has("position"):
		pos2d = world_data.get_game_pos(result["position"])
	return pos2d

func _on_Select_pressed():
	mode = MODE_SELECT
	$Selection.state = $Selection.STATE_NORMAL
	$Selection.update()

func _on_Units_mode_wagon():
	emit_signal("select", null)
	mode = MODE_WAGON

func _on_Move_pressed():
	if $Selection.is_visible_in_tree():
		mode = MODE_MOVE
		$Selection.state = $Selection.STATE_MOVE
		$Selection.update()

func _on_GameData_actor_placed(actor, pos):
	_on_GameData_actor_moved(actor, pos)
	add_child(actor)

func _on_GameData_actor_moved( actor, pos ):
	actor.translation = world_data.get_world_pos(pos)
	actor.translation.y = world_data.get_terrain_mesh_height(actor.translation)

func _on_GameData_selected( pos ):
	if pos:
		$Selection.state = $Selection.STATE_NORMAL
		$Selection.translation = world_data.get_world_pos(pos)
		$Selection.update()
		$Selection.show()
	else:
		$Selection.hide()
