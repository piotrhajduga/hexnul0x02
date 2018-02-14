extends Area

onready var terrain = get_parent()
onready var cols = terrain.cols
onready var rows = terrain.rows

onready var globals = get_node("/root/GameWorldGlobals")
onready var game_world = get_parent().get_parent()
onready var world_data = game_world.get_node("WorldData")
onready var collision = get_node("CollisionShape")
	
func get_world_point(x,y):
	var pt = globals.get_world_coords(x,y)
	pt.y = world_data.get_terrain_mesh_height(pt)
	return pt

func _ready():
	var points = PoolVector3Array()
	
	for x in range((-cols/2)-1,cols/2+1):
		for y in range((-rows/2)-1,rows/2+1):
			points.append(get_world_point(x,y))
			points.append(get_world_point(x,y+1))
			points.append(get_world_point(x+1,y+1))
			points.append(get_world_point(x+1,y+1))
			points.append(get_world_point(x+1,y))
			points.append(get_world_point(x,y))
	collision.shape = ConcavePolygonShape.new()
	collision.shape.set_faces(points)
	collision.disabled = false