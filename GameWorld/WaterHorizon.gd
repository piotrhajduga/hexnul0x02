extends MeshInstance

func _ready():
	pass

func _on_GameCamera_moved(target_position, camera_y_angle):
	pass
#	self.translation = self.translation * Vector3(0,1,0) + target_position * Vector3(1,0,1)
#	self.rotation = Vector3(0,1,0) * camera_y_angle
#	self.translate(Vector3(0,0,-20))