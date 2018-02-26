extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.gd")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Material) var material = null

enum SelectionState {
	STATE_NORMAL
}

var STATE_COLORS = {
	STATE_NORMAL: Color("#fefced")
}
export(SelectionState) var state = STATE_NORMAL setget set_state
var cell = null

func set_state(val):
	if val: state = val

func _ready():
	cell = Cell.new(world_data, material)
	cell.translation.y = 0.01
	add_child(cell)
	light.translation.y = light_height + world_data.get_terrain_mesh_height(self.translation)

func update():
	light.light_color = STATE_COLORS[state]
	material.set_shader_param("albedo", STATE_COLORS[state])
	cell.update_shape()