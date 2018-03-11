extends Spatial

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

func _ready():
	for objects in get_children():
		objects.translation.y = world_data.get_terrain_mesh_height(to_global(objects.translation))