extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	self.set_anchor(MARGIN_BOTTOM, 0.2, true, true)
	self.set_anchor(MARGIN_RIGHT, 0.2, true, true)

func _input():