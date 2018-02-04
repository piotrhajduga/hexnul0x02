extends Camera

onready var globals = get_node("/root/TerrainGlobals")

const up = Vector3(0.0,1.0,0.0)

var max_camera_height = 60.0
var min_camera_height = 3.0

enum camera_movement {CAM_HI, CAM_LO}

export(Vector3) var target_position = Vector3()
export(Vector3) var camera_offset = Vector3(0.0,3.0,7.0)
export(float,0,100) var camera_height = 5.0

export var camera_vspeed = 1.0
export var camera_hspeed = 1.0

func _ready():
	move(Vector2())
	look_at_target()
	self.camera_vspeed = camera_height * 0.01
	
func look_at_target():
	self.look_at_from_position(target_position+camera_offset+(up*camera_height),target_position,up)
	
func set_height(new_height):
	if new_height >= min_camera_height and new_height <= max_camera_height:
		self.camera_height = new_height
		self.camera_vspeed = new_height * 0.02

func move(relative):
	target_position.x += relative.x * camera_vspeed
	target_position.z += relative.y * camera_vspeed
	min_camera_height = globals.get_terrain_mesh_height(target_position.x, target_position.z)
	if camera_height < min_camera_height:
		set_height(min_camera_height)
	
func move_camera(dir):
	var new_height
	match dir:
		CAM_HI: new_height = camera_height + camera_hspeed
		CAM_LO: new_height = camera_height - camera_hspeed
	set_height(new_height)