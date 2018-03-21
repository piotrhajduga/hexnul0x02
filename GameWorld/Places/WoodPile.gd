tool
extends Spatial

export(int) var count = 5 setget set_count
var ready = false

func inc():
	self.count += 1

func dec():
	self.count -= 1

func set_count(val):
	count = val
	if ready:
		for x in range(1,11):
			var pile = get_node("WoodPile"+String(x))
			if count < x: pile.hide()
			else: pile.show()

func _ready():
	ready = true