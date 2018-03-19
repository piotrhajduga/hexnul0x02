extends MenuButton

signal mode_house

enum {HOUSE}

func _ready():
	get_popup().add_item("House", HOUSE)
	get_popup().connect("id_pressed", self, "_on_id_pressed")

func _on_id_pressed(id):
	match(id):
		HOUSE: emit_signal("mode_house")