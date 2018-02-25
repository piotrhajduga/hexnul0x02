extends Spatial

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

func _on_GameData_actor_placed(actor, pos):
	_on_GameData_actor_moved(actor, pos)
	add_child(actor)

func _on_GameData_actor_moved( actor, pos ):
	actor.translation = world_data.get_world_pos(pos)
	actor.translation.y = world_data.get_terrain_mesh_height(actor.translation)