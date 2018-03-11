extends Spatial

var GameLogicClass = preload("res://GameLogic.gd")

var Cell = preload("res://GameWorld/Terrain/Cell.tscn")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Material) var material = null

enum SelectionState {
	STATE_NORMAL, STATE_MOVE
}
export(SelectionState) var state = STATE_NORMAL setget set_state

export(Color) var normal_color = Color("#c3cfb2")
export(Color) var move_passable_color = Color("#23fdf2")

onready var STATE_COLORS = {
	STATE_NORMAL: normal_color,
	STATE_MOVE: move_passable_color
}

var cells = []

func set_state(val):
	if val==null: return
	state = val

func _ready():
	update()
	light.translation.y = light_height + world_data.get_terrain_mesh_height(self.translation)

func update():
	light.light_color = STATE_COLORS[state]
	material.set_shader_param("albedo", STATE_COLORS[state])
	$Pathfinder.game_pos = world_data.get_game_pos(self.translation)
	$Pathfinder.update()
	for cell in cells:
		remove_child(cell)
		cell.queue_free()
	cells.clear()
	for rcpos in world_data.get_cells_in_radius($Pathfinder.game_pos, {
		STATE_NORMAL: 0,
		STATE_MOVE: $Pathfinder.radius
	}[state]):
		if state != STATE_MOVE or $Pathfinder.is_passable(rcpos):
			var cell = Cell.instance()
			cell.world_data = world_data
			cell.material = material
			cells.append(cell)
			add_child(cell)
			cell.translation = world_data.get_world_pos(rcpos) - world_data.get_world_pos($Pathfinder.game_pos) + Vector3(0,1,0)*0.01
			cell.update_shape()

func _on_GameLogic_change_mode(mode):
	match(mode):
		GameLogicClass.MODE_SELECT:
			self.state = STATE_NORMAL
		GameLogicClass.MODE_MOVE:
			self.state = STATE_MOVE
	update()

func _on_GameLogic_selected(object):
	if object:
		self.translation = object.translation * Vector3(1,0,1)
		update()
		show()
	else:
		hide()