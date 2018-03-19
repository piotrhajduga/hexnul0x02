extends Panel

func _ready():
	update_size()
	get_viewport().connect("size_changed", self, "update_size")

func update_size():
	var vport_rect = get_viewport_rect()
	self.rect_position = vport_rect.position + vport_rect.size - self.rect_size - Vector2(8,8)

func _unhandled_key_input(event):
	match(event.scancode):
		KEY_SPACE:
			self.rect_position = get_global_mouse_position()