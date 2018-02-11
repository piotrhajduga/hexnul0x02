extends Spatial

var Cell = preload("Cell.gd")

export(int) var cols = 60
export(int) var rows = 40

onready var globals = get_node("/root/GameWorldGlobals")
onready var game_world = get_parent()
onready var collision = get_node("Area/CollisionShape")

export(Material) var water = preload("Water.tres.material")
export(Material) var sand = preload("Sand.tres.material")
export(Material) var grass = preload("Grass.tres.material")
export(Material) var stone = preload("Stone.tres.material")
export(Material) var snow = preload("Snow.tres.material")

func get_material(cell_type):
	match cell_type:
		game_world.SNOW: return snow
		game_world.STONE: return stone
		game_world.GRASS: return grass
		game_world.SAND: return sand
		_: return water

func create_cell(pos, cell_type):
	var cell = Cell.new(game_world, get_material(cell_type))
	cell.scale = Vector3(1.005,1.0,1.005)
	return cell
	
func get_world_point(x,y):
	var pt = globals.get_world_coords(x,y)
	pt.y = game_world.get_terrain_mesh_height(pt)
	return pt

func _ready():
	var points = PoolVector3Array()
	
	for x in range((-cols/2)-1,cols/2+1):
		for y in range((-rows/2)-1,rows/2+1):
			if x >= -cols/2 && y >= -rows/2:
				var world_coords = globals.get_world_coords(x,y)
				var height = game_world.get_height(world_coords)
				var cell_type = game_world.get_cell_type(height)
				var cell = create_cell(world_coords, cell_type)
				add_child(cell)
				cell.global_translate(world_coords)
				cell.update_shape()
		
			points.append(get_world_point(x,y))
			points.append(get_world_point(x,y+1))
			points.append(get_world_point(x+1,y+1))
			points.append(get_world_point(x+1,y+1))
			points.append(get_world_point(x+1,y))
			points.append(get_world_point(x,y))
	var shape = ConcavePolygonShape.new()
	shape.set_faces(points)
	collision.shape = shape
	collision.disabled = false
