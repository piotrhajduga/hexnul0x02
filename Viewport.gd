extends Viewport

onready var container = get_parent()
onready var game_world = get_node("GameWorld")

func _ready():
	self.size = container.get_viewport_rect().size

func _on_ViewportContainer_mouse_entered():
	self.gui_disable_input = false

func _on_ViewportContainer_mouse_exited():
	self.gui_disable_input = true


func _on_ViewportContainer_resized():
	if container:
		self.size = container.get_viewport_rect().size
