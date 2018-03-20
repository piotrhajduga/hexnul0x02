extends MeshInstance

const xStep = 1.0
const zStep = sqrt(3.0) / 2.0

var outline = [
	Vector3(-xStep,0.0,0.0),Vector3(-0.5*xStep,0.0,zStep),
	Vector3(0.5*xStep,0.0,zStep),Vector3(xStep,0.0,0.0),
	Vector3(0.5*xStep,0.0,-zStep),Vector3(-0.5*xStep,0.0,-zStep)
]

var outlineUVs = [
	Vector2(0.0,0.5),Vector2(0.25,0.0),
	Vector2(0.75,0.0),Vector2(1.0,0.5),
	Vector2(0.75,1.0),Vector2(0.25,1.0)
]

export(bool) var surface = false
var world_data = null
var material = null
var global_pos = null

func get_normal(pos):
	if surface: return world_data.get_surface_normal(pos)
	else: return world_data.get_normal(pos)

var normals = {}
func get_neighbor_normal(i):
	if normals.has(i): return normals[i]
	if i < 7:
		normals[i] = get_normal(to_global(outline[i]))
	else:
		normals[i] = get_normal(to_global(Vector3()))
	return normals[i]

func get_height(pos):
	if surface: return world_data.get_surface_height(pos)
	else: return world_data.get_terrain_mesh_height(pos)

var heights = {}
func get_neighbor_height(i):
	if heights.has(i): return heights[i]
	if i < 7:
		heights[i] = get_height(to_global(outline[i]))
	else:
		heights[i] = get_height(to_global(Vector3()))
	return heights[i]
	
func add_vertex(surfTool, i):
	var pos = outline[i] if i<7 else Vector3()
	var uv = outlineUVs[i] if i<7 else Vector2(0.5,0.5)
	var normal = get_neighbor_normal(i)
	var height = get_neighbor_height(i)
	surfTool.add_normal(normal)
	surfTool.add_uv(uv)
	surfTool.add_vertex(pos + Vector3(0.0, height, 0.0))

func _ready():
	pass
	
func update():
	call_deferred("update_shape")

func update_shape():
	heights.clear()
	normals.clear()
	var new_mesh = Mesh.new()
	var surfTool = SurfaceTool.new()
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfTool.add_smooth_group(true)
	
	for i in range(6):
		add_vertex(surfTool, 7)
		add_vertex(surfTool, i)
		add_vertex(surfTool, (i-1)%6)
	#surfTool.generate_normals()
	surfTool.generate_tangents()
	surfTool.index()
	surfTool.set_material(material)
	surfTool.commit(new_mesh)
	set_mesh(new_mesh)