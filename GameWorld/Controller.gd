extends Node

onready var globals = get_node("/root/GameWorldGlobals")
onready var game_world = get_parent()
onready var camera = game_world.get_node("Camera")
onready var terrain = game_world.get_node("Terrain")
onready var hover = game_world.get_node("Hover")

var mouse_pos = Vector2()

func _ready():
	camera.target_position = terrain.translation

func handle_mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP: camera.move_camera(camera.CAM_LO)
		BUTTON_WHEEL_DOWN: camera.move_camera(camera.CAM_HI)
		BUTTON_RIGHT:
			if hover.is_visible():
				create_unit(hover.translation)
	
func handle_mouse_motion(event):
	if event.button_mask & BUTTON_MASK_LEFT:
		var relative = event.relative
		camera.move(relative)
		hover.hide()
	if event.button_mask & BUTTON_MASK_MIDDLE:
		hover.hide()
		if event.relative.x > 0:
			camera.move_camera(camera.CAM_TURN_LEFT)
		else:
			camera.move_camera(camera.CAM_TURN_RIGHT)
	elif event.button_mask == 0:
		mouse_pos = event.position
		set_physics_process(true)

func _physics_process(delta):
	set_physics_process(false)
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state = game_world.get_world().get_direct_space_state()

	var result = space_state.intersect_ray(from, to)
	if result.has("position") and (result["position"]-camera.target_position).length() < 10 + 8 * log(camera.camera_height):
		var pos2d = globals.get_game_coords(result["position"])
		hover.translation = globals.get_world_coords(pos2d.x, pos2d.y)
		hover.translation.y = game_world.get_terrain_mesh_height(hover.translation)
		hover.show()
	else:
		hover.hide()
		
func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)