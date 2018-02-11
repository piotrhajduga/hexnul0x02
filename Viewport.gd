extends Viewport

onready var container = get_parent()

func _ready():
	self.size = container.get_viewport_rect().size