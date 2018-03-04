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

var world_data = null
var material = null
var global_pos = null

var normals = {}
func get_normal(i):
	if normals.has(i): return normals[i]
	if i < 7:
		normals[i] = world_data.get_normal(to_global(outline[i]))
	else:
		normals[i] = world_data.get_normal(to_global(Vector3()))
	return normals[i]
	
var heights = {}
func get_height(i):
	if heights.has(i): return heights[i]
	if i < 7:
		heights[i] = world_data.get_terrain_mesh_height(to_global(outline[i]))
	else:
		heights[i] = world_data.get_terrain_mesh_height(to_global(Vector3()))
	return heights[i]
	
func add_vertex(surfTool, i):
	var pos = outline[i] if i<7 else Vector3()
	var uv = outlineUVs[i] if i<7 else Vector2(0.5,0.5)
	var normal = get_normal(i)
	var height = get_height(i)
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