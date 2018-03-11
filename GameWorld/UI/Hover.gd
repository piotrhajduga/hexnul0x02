extends Spatial

var GameLogicClass = preload("res://GameLogic.gd")

var Cell = preload("res://GameWorld/Terrain/Cell.tscn")

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
var cell = null

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
	if cell and light: update()

func _ready():
	cell = Cell.instance()
	cell.world_data = world_data
	cell.material = material
	cell.translation.y = 0.01
	add_child(cell)
	light.translation.y = light_height + world_data.get_terrain_mesh_height(self.translation)

func update():
	light.light_color = STATE_COLORS[state]
	material.set_shader_param("albedo", STATE_COLORS[state])
	cell.update_shape()

func _on_GameLogic_change_mode(mode):
	match(mode):
		GameLogicClass.MODE_MOVE: show()
		GameLogicClass.MODE_PLACE: show()
		GameLogicClass.MODE_SELECT: show()
		GameLogicClass.MODE_IDLE: hide()
	set_game_pos(game_space.world_to_offset(self.translation))
	update()