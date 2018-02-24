extends Spatial

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

signal wagon(game_pos)
signal select(game_pos)
signal move(game_pos)

var mouse_pos = Vector2()
var selected = Vector2()

enum {MODE_IDLE,MODE_SELECT,MODE_WAGON,MODE_MOVE}
var mode = MODE_IDLE

func _ready():
	$GameCamera.target_position = $Terrain.translation
	$Hover.hide()

func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)

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
	mode = MODE_IDLE
	$Hover.hide()
	
func handle_mouse_motion(event):
	if event.button_mask & BUTTON_MASK_RIGHT:
		var relative = event.relative
		$GameCamera.move(relative)
		$Hover.hide()
	elif event.button_mask & BUTTON_MASK_MIDDLE:
		$Hover.hide()
		if event.relative.x > 0:
			$GameCamera.move_camera($GameCamera.CAM_TURN_LEFT)
		else:
			$GameCamera.move_camera($GameCamera.CAM_TURN_RIGHT)
	elif mode != MODE_IDLE:
		mouse_pos = get_viewport().get_mouse_position()
		selected = select_cell()

func select_cell():
	var ray_length = 100
	var from = $GameCamera.project_ray_origin(mouse_pos)
	var to = from + $GameCamera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()
	var pos2d = null

	var result = space_state.intersect_ray(from, to)
	if result.has("position"):
		pos2d = world_data.get_game_pos(result["position"])
		$Hover.translation = world_data.get_world_pos(pos2d)
		$Hover.update_shape()
		$Hover.show()
	else:
		$Hover.hide()
	return pos2d

func _on_Select_pressed():
	mode = MODE_SELECT

func _on_Units_mode_wagon():
	emit_signal("select", null)
	mode = MODE_WAGON

func _on_Move_pressed():
	mode = MODE_MOVE

func _on_GameData_actor_placed(actor, pos):
	_on_GameData_actor_moved(actor, pos)
	add_child(actor)

func _on_GameData_actor_moved( actor, pos ):
	actor.translation = world_data.get_world_pos(pos)
	actor.translation.y = world_data.get_terrain_mesh_height(actor.translation)

func _on_GameData_selected( pos ):
	$Selection.translation = world_data.get_world_pos(pos)
	$Selection.update_shape()
	$Selection.show()

func _on_GameData_deselected():
	$Selection.hide()
