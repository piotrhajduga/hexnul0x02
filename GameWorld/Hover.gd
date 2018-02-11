extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.gd")

onready var game_world = get_parent()
onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Material) var material = null

var cell = null

func _ready():
	add_cell()

func update_shape():
	cell.update_shape()

func add_cell():
	cell = Cell.new(game_world, material)
	cell.translation = Vector3(0.0,0.01,0.0)
	add_child(cell)
	light.translation.y = light_height + game_world.get_terrain_mesh_height(self.translation)