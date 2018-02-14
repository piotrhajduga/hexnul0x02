extends Spatial

signal wagon(game_pos)
signal select(game_pos)
signal move(game_pos)

onready var globals = get_node("/root/GameWorldGlobals")
onready var world_data = get_node("WorldData")
onready var camera = get_node("Camera")
onready var terrain = get_node("Terrain")

var mouse_pos = Vector2()
var selected = Vector2()

enum {MODE_IDLE,MODE_SELECT,MODE_WAGON,MODE_MOVE}
var mode = MODE_IDLE

func _ready():
	camera.target_position = terrain.translation
	$Hover.hide()

func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)

func handle_mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP:
			camera.move_camera(camera.CAM_LO)
			$Hover.hide()
		BUTTON_WHEEL_DOWN:
			camera.move_camera(camera.CAM_HI)
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
		camera.move(relative)
		$Hover.hide()
	elif event.button_mask & BUTTON_MASK_MIDDLE:
		$Hover.hide()
		if event.relative.x > 0:
			camera.move_camera(camera.CAM_TURN_LEFT)
		else:
			camera.move_camera(camera.CAM_TURN_RIGHT)
	elif mode != MODE_IDLE:
		mouse_pos = get_viewport().get_mouse_position()
		selected = select_cell()

func select_cell():
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()
	var pos2d = null

	var result = space_state.intersect_ray(from, to)
	if result.has("position"):
		pos2d = globals.get_game_coords(result["position"])
		$Hover.translation = globals.get_world_coords(pos2d.x, pos2d.y)
		$Hover.update_shape()
		$Hover.show()
	else:
		$Hover.hide()
	return pos2d

func _on_Select_pressed():
	mode = MODE_SELECT
	
func _on_Wagon_pressed():
	mode = MODE_WAGON

func _on_Move_pressed():
	mode = MODE_MOVE

func _on_GameData_actor_placed(actor, pos):
	_on_GameData_actor_moved(actor, pos)
	add_child(actor)

func _on_GameData_actor_moved( actor, pos ):
	actor.translation = globals.get_world_coords(pos.x, pos.y)
	actor.translation.y = world_data.get_terrain_mesh_height(actor.translation)

func _on_GameData_selected( pos ):
	$Selection.translation = globals.get_world_coords(pos.x, pos.y)
	$Selection.update_shape()
	$Selection.show()

func _on_GameData_deselected():
	$Selection.hide()
