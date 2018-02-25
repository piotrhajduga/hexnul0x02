extends Camera

signal moved (target_position, camera_y_angle)

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

const up = Vector3(0.0,1.0,0.0)

var max_camera_height = 30.0
var min_camera_height = 2.0

enum camera_movement {CAM_HI, CAM_LO, CAM_TURN_LEFT, CAM_TURN_RIGHT}

export(Vector3) var target_position = Vector3()
export(Vector3) var camera_offset = Vector3(0.0,3.0,10.0)
export(float,0,100) var camera_height = 5.0

export var camera_vspeed = 1.0
export var camera_hspeed = 1.0

export var camera_y_angle = 0.0

func _ready():
	move(Vector2())
	set_height(camera_height)
	look_at_target()
	
func look_at_target():
	self.look_at_from_position(target_position+(camera_offset.rotated(up,camera_y_angle))+(up*camera_height),target_position,up)
	
func set_height(new_height):
	if new_height >= min_camera_height and new_height <= max_camera_height:
		self.camera_height = new_height
		self.camera_vspeed = 0.007 * camera_height

func move(relative2d):
	var relative3d = Vector3(relative2d.x,0.0,relative2d.y).rotated(up,camera_y_angle)
	target_position -= relative3d * camera_vspeed
	min_camera_height = world_data.get_terrain_mesh_height(target_position)
	if camera_height < min_camera_height:
		set_height(min_camera_height)
	emit_signal("moved", target_position, camera_y_angle)
	look_at_target()
	
func move_camera(dir):
	match dir:
		CAM_HI: set_height(camera_height + camera_hspeed)
		CAM_LO: set_height(camera_height - camera_hspeed)
		CAM_TURN_LEFT: camera_y_angle -= PI/30
		CAM_TURN_RIGHT: camera_y_angle += PI/30
	emit_signal("moved", target_position, camera_y_angle)
	look_at_target()