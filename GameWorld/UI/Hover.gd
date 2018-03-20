extends Spatial

var GameLogicClass = load("res://GameLogic.gd")

var Cell = load("res://GameWorld/Terrain/Cell.tscn")

onready var game_space = get_node("/root/GameSpace")
export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)
export(NodePath) var game_logic_node
onready var game_logic = get_node(game_logic_node)
export(NodePath) var pathfinder_node
onready var pathfinder = get_node(pathfinder_node)

onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Material) var material = null

enum HoverState {
	STATE_HOVER,
	STATE_MOVE_PASSABLE,
	STATE_MOVE_IMPASSABLE,
	STATE_PLACE_UNIT
}

export(Color) var hover_color = Color("#c3cfb2")
export(Color) var move_passable_color = Color("#23fdf2")
export(Color) var move_impassable_color = Color("#ed6d35")
export(Color) var place_unit_color = Color("#6dad35")

var STATE_COLORS = {
	STATE_HOVER: hover_color,
	STATE_MOVE_PASSABLE: move_passable_color,
	STATE_MOVE_IMPASSABLE: move_impassable_color,
	STATE_PLACE_UNIT: place_unit_color
}
export(HoverState) var state = STATE_HOVER setget set_state

func set_game_pos(game_pos):
	if game_pos == null:
		self.hide()
		return
	self.translation = game_space.offset_to_world(game_pos)
	match(game_logic.mode):
		GameLogicClass.MODE_MOVE:
			if pathfinder.is_passable(game_pos):
				self.state = STATE_MOVE_PASSABLE 
			else:
				self.state = STATE_MOVE_IMPASSABLE
		GameLogicClass.MODE_PLACE:
			if world_data.is_passable(game_pos):
				self.state = STATE_PLACE_UNIT
			else:
				self.state = STATE_MOVE_IMPASSABLE
		GameLogicClass.MODE_SELECT:
			self.state = STATE_HOVER

func set_state(val):
	if val==null: return
	state = val
	if light: update()

func _ready():
	update()

func _add_cell(world_pos):
	var cell = Cell.instance()
	cell.surface = true
	cell.world_data = world_data
	cell.material = material
	cell.translation = world_pos - self.translation
	cell.translation.y = 0.01
	add_child(cell)
	cell.update_shape()
	
func update():
	for cell in get_children():
		remove_child(cell)
	light.translation.y = light_height + world_data.get_surface_height(self.translation)
	light.light_color = STATE_COLORS[state]
	material.set_shader_param("albedo", STATE_COLORS[state])
	if state == STATE_MOVE_PASSABLE and game_logic.selected:
		for offset in pathfinder.get_path(game_logic.selected.game_position, game_space.world_to_offset(self.translation)):
			_add_cell(game_space.offset_to_world(offset))
	else:
		_add_cell(self.translation)

func _on_GameLogic_change_mode(mode):
	match(mode):
		GameLogicClass.MODE_MOVE: show()
		GameLogicClass.MODE_PLACE: show()
		GameLogicClass.MODE_SELECT: show()
		GameLogicClass.MODE_IDLE: hide()
	set_game_pos(game_space.world_to_offset(self.translation))
	update()