extends Spatial

var GameLogicClass = preload("res://GameLogic.gd")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

onready var game_space = get_node("/root/GameSpace")
onready var pathfinder = $Selection.get_node("Pathfinder")

var Wagon = preload("res://GameWorld/Units/Wagon.tscn")
var House = preload("res://GameWorld/Places/House.tscn")

signal change_mode(mode)
signal change_place_mode(mode,ObjectClass)
signal select(game_pos)

func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)
		"InputEventKey": handle_keypress(event)

func handle_keypress(event):
	match event.scancode:
		KEY_P: emit_signal("change_mode", GameLogicClass.MODE_PLACE)
		KEY_W:
			emit_signal("change_place_mode", GameLogicClass.OBJECT_UNIT, Wagon)
			emit_signal("change_mode", GameLogicClass.MODE_PLACE)
		KEY_H:
			emit_signal("change_place_mode", GameLogicClass.OBJECT_PLACE, House)
			emit_signal("change_mode", GameLogicClass.MODE_PLACE)
		KEY_M: emit_signal("change_mode", GameLogicClass.MODE_MOVE)
		KEY_S: emit_signal("change_mode", GameLogicClass.MODE_SELECT)
		KEY_ESCAPE: emit_signal("change_mode", GameLogicClass.MODE_IDLE)

func handle_mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP:
			$GameCamera.move_camera($GameCamera.CAM_LO)
		BUTTON_WHEEL_DOWN:
			$GameCamera.move_camera($GameCamera.CAM_HI)
		BUTTON_LEFT:
			if !event.is_pressed(): emit_signal("select", get_cell_on_hover())

func handle_mouse_motion(event):
	if event.button_mask & BUTTON_MASK_RIGHT:
		var relative = event.relative
		$GameCamera.move(relative)
	elif event.button_mask & BUTTON_MASK_MIDDLE:
		if event.relative.x > 0:
			$GameCamera.move_camera($GameCamera.CAM_TURN_LEFT)
		else:
			$GameCamera.move_camera($GameCamera.CAM_TURN_RIGHT)
	else:
		$Hover.set_game_pos(get_cell_on_hover())

var ray_length = 100
func get_cell_on_hover():
	var mouse_pos = get_viewport().get_mouse_position()
	var pos2d = null
	var from = $GameCamera.project_ray_origin(mouse_pos)
	var to = from + $GameCamera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if result.has("position"):
		pos2d = world_data.get_game_pos(result["position"])
	return pos2d