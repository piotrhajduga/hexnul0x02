extends ViewportContainer

onready var viewport = get_node("Viewport")

func _ready():
	viewport.size = self.rect_size
