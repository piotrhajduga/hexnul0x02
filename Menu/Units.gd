extends MenuButton

signal mode_wagon

enum {WAGON}

func _ready():
	get_popup().add_item("Wagon", WAGON)
	get_popup().connect("id_pressed", self, "_on_id_pressed")

func _on_id_pressed(id):
	match(id):
		WAGON: emit_signal("mode_wagon")