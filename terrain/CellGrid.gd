extends Spatial

var Cell = preload("res://terrain/Cell.gd")

export(int) var cols = 60
export(int) var rows = 40

onready var globals = get_node("/root/TerrainGlobals")
onready var collision = get_node("Area/CollisionShape")

export(Material) var water = preload("res://terrain/Water.tres.material")
export(Material) var sand = preload("res://terrain/Sand.tres.material")
export(Material) var grass = preload("res://terrain/Grass.tres.material")
export(Material) var stone = preload("res://terrain/Stone.tres.material")
export(Material) var snow = preload("res://terrain/Snow.tres.material")

func get_material(cell_type):
	match cell_type:
		globals.SNOW: return snow
		globals.STONE: return stone
		globals.GRASS: return grass
		globals.SAND: return sand
		_: return water

func create_cell(coords):
	var cell = Cell.new(coords, globals.water_height)
	cell.scale = Vector3(1.005,1.0,1.005)
	return cell
	
func get_world_point(x,y):
	var pt = globals.get_world_coords(x,y)
	pt.y = globals.get_terrain_mesh_height(x,y)
	return pt

func _ready():
	var points = PoolVector3Array()
	
	for x in range((-cols/2)-1,cols/2+1):
		for y in range((-rows/2)-1,rows/2+1):
			if x >= -cols/2 && y >= -rows/2:
				var world_coords = globals.get_world_coords(x,y)
				var cell = create_cell(world_coords)
				var height = globals.get_height(world_coords.x,world_coords.z)
				var cell_type = globals.get_cell_type(height)
				add_child(cell)
				cell.global_translate(world_coords)
				cell.set_surface_material(0, get_material(cell_type))
		
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
