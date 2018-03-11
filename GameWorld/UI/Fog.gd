extends MeshInstance

func _on_GameCamera_moved(target_position, camera_y_angle):
	self.translation = target_position
