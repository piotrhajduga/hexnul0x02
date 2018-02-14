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

onready var globals = get_node("/root/GameWorldGlobals")

var water_level = 0.0
var world_data = null
var material = null

func _init(world_data, material):
	self.world_data = world_data
	self.material = material

func add_vertex(surfTool, uv, pos):
	var height = world_data.get_terrain_mesh_height(to_global(pos))
	surfTool.add_uv(uv)
	surfTool.add_vertex(pos + Vector3(0.0, height, 0.0))

func _ready():
	update_shape()

func update_shape():
	var new_mesh = Mesh.new()
	var surfTool = SurfaceTool.new()
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surfTool.add_smooth_group(true)
	for i in range(6):
		add_vertex(surfTool, Vector2(0.5,0.5), Vector3())
		add_vertex(surfTool, outlineUVs[i], outline[i])
		add_vertex(surfTool, outlineUVs[i-1], outline[i-1])
	surfTool.generate_normals()
	surfTool.generate_tangents()
	surfTool.index()
	surfTool.set_material(material)
	surfTool.commit(new_mesh)
	set_mesh(new_mesh)