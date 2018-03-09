extends Spatial

export(NodePath) var world_data_node
var world_data

func _ready():
	for tree in self.get_children():
		tree.translation.y = world_data.get_terrain_mesh_height(to_global(tree.translation))