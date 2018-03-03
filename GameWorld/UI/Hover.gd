extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.tscn")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

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