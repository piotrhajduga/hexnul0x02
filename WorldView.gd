extends Spatial

onready var globals = get_node("/root/global")

onready var camera = get_node("Camera")
onready var cell_grid = get_node("CellGrid")
onready var hover = get_node("Hover")
onready var collision_plane = get_node("Area")

var mouse_pos = Vector2()

func _ready():
	camera.target_position = cell_grid.to_global(Vector3())
	collision_plane.translation.x = camera.translation.x
	collision_plane.translation.y = globals.TERRAIN_HEIGHT_SCALE * cell_grid.water_height * cell_grid.water_height
	collision_plane.translation.z = camera.translation.z

func handle_mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP: camera.move_camera(camera.CAM_LO)
		BUTTON_WHEEL_DOWN: camera.move_camera(camera.CAM_HI)
	camera.look_at_target()
	
func handle_mouse_motion(event):
	mouse_pos = event.position
	set_physics_process(true)
	
	if event.button_mask & BUTTON_MASK_LEFT || event.alt:
		var relative = event.relative
		camera.move(relative)
		collision_plane.translation.x = camera.translation.x
		#collision_plane.translation.y = cell_grid.water_height
		collision_plane.translation.z = camera.translation.z
		camera.look_at_target()

func _physics_process(delta):
	var ray_length = 100
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	
	if result.has("position"):
		var pos2d = cell_grid.get_game_coords(result["position"])
		var pos3d = cell_grid.get_world_coords(pos2d.x,pos2d.y)
		var height = globals.get_height(pos3d.x,pos3d.z)
		if height < cell_grid.water_height: height = cell_grid.water_height
		pos3d.y = 0.1 + (globals.TERRAIN_HEIGHT_SCALE * height * height)
		hover.translation = pos3d
		hover.show()
	else:
		hover.hide()
	set_physics_process(false)
		
func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)