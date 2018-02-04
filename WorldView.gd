extends Spatial

onready var globals = get_node("/root/TerrainGlobals")

onready var camera = get_node("Camera")
onready var cell_grid = get_node("CellGrid")
onready var hover = get_node("Hover")
onready var collision_plane = get_node("Area")

var mouse_pos = Vector2()
var mouse_probe_delta = 0.5

func _ready():
	camera.target_position = cell_grid.translation
	collision_plane.translation = camera.translation

func handle_mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP: camera.move_camera(camera.CAM_LO)
		BUTTON_WHEEL_DOWN: camera.move_camera(camera.CAM_HI)
	camera.look_at_target()
	
func handle_mouse_motion(event):
	if event.button_mask & BUTTON_MASK_LEFT || event.alt:
		var relative = event.relative
		camera.move(relative)
		collision_plane.translation = camera.translation
		camera.look_at_target()
	else:
		mouse_pos = event.position
		set_physics_process(true)

var debug_hi = 0.0

func _physics_process(delta):
	set_physics_process(false)
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()

	var pos3d = null
	
	var probe_height = globals.TERRAIN_HEIGHT_SCALE
	var min_err = globals.TERRAIN_HEIGHT_SCALE
	
	while probe_height > -mouse_probe_delta:
		collision_plane.translation.y = probe_height
		var result = space_state.intersect_ray(from, to)
		if result.has("position"):
			var pos2d = globals.get_game_coords(result["position"])
			var tpos3d = globals.get_world_coords(pos2d.x,pos2d.y)
			tpos3d.y = globals.get_terrain_mesh_height(tpos3d.x,tpos3d.z)
			var err = (tpos3d - result["position"]).length()
			if err < min_err:
				pos3d = tpos3d
				min_err = err
		probe_height -= mouse_probe_delta
	if pos3d != null:
		hover.translation = pos3d
		hover.show()
	else:
		hover.hide()
		
func _input(event):
	match event.get_class():
		"InputEventMouseButton": handle_mouse_button(event)
		"InputEventMouseMotion": handle_mouse_motion(event)