extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.gd")

onready var world_data = get_parent().get_node("WorldData")
onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Color) var light_color = null
export(Material) var material = null

var cell = null

func _ready():
	cell = Cell.new(world_data, material)
	add_child(cell)
	light.translation.y = light_height + world_data.get_terrain_mesh_height(self.translation)
	if light_color:
		light.light_color = light_color

func update_shape():
	cell.update_shape()