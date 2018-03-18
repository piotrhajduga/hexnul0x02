extends Spatial

var GameLogicClass = load("res://GameLogic.gd")

var Cell = load("res://GameWorld/Terrain/Cell.tscn")

onready var game_space = get_node("/root/GameSpace")
export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)
export(NodePath) var pathfinder_node
onready var pathfinder = get_node(pathfinder_node)

onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Material) var material = null

enum SelectionState {
	STATE_NORMAL, STATE_MOVE
}
export(SelectionState) var state = STATE_NORMAL setget set_state
export(int) var radius = 0

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
	var game_pos = game_space.world_to_offset(self.translation)
	for cell in cells:
		remove_child(cell)
		cell.queue_free()
	cells.clear()
	for rcpos in game_space.offset_range(game_pos, radius):
		var cell = Cell.instance()
		cell.world_data = world_data
		cell.material = material
		cells.append(cell)
		add_child(cell)
		var rcworld = game_space.offset_to_world(rcpos)
		var world_pos = game_space.offset_to_world(game_pos)
		cell.translation = rcworld - world_pos + Vector3(0,1,0) * 0.01
		cell.update_shape()

func _on_GameLogic_change_mode(mode):
	match(mode):
		GameLogicClass.MODE_SELECT:
			self.state = STATE_NORMAL
		GameLogicClass.MODE_MOVE:
			self.state = STATE_MOVE
		_:
			self.state = STATE_NORMAL
	update()

func _on_GameLogic_selected(object):
	if object:
		self.translation = object.translation * Vector3(1,0,1)
		update()
		show()
	else:
		hide()