extends MeshInstance

const xStep = 1.0
const zStep = sqrt(3.0) / 2.0

var outline = [
	Vector3(-xStep,0.0,0.0),Vector3(-0.5*xStep,0.0,zStep),
	Vector3(0.5*xStep,0.0,zStep),Vector3(xStep,0.0,0.0),
	Vector3(0.5*xStep,0.0,-zStep),Vector3(-0.5*xStep,0.0,-zStep)
]

var outlineUVs = [
	Vector2(-1.0,0.0),Vector2(-0.5,1.0),
	Vector2(0.5,1.0),Vector2(1.0,0.0),
	Vector2(0.5,-1),Vector2(-0.5,-1)
]

onready var globals = get_node("/root/global")

var world_pos = Vector3()
var water_level = 0.0

func _init(pos, water_level):
	self.world_pos = pos
	self.water_level = water_level

func add_vertex(surfTool, uv, pos):
	var height = globals.get_height(world_pos.x+pos.x,world_pos.z+pos.z)
	if height < water_level: height = water_level
	var up = Vector3(0.0, globals.TERRAIN_HEIGHT_SCALE * height * height, 0.0)
	surfTool.add_uv(uv)
	surfTool.add_vertex(pos+up)

func create_mesh():
	var new_mesh = Mesh.new()

	var surfTool = SurfaceTool.new()
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
		
	for i in range(6):
		surfTool.add_smooth_group(true)
		add_vertex(surfTool, Vector2(), Vector3())
		surfTool.add_smooth_group(false)
		add_vertex(surfTool, outlineUVs[i], outline[i])
		add_vertex(surfTool, outlineUVs[i-1], outline[i-1])
	surfTool.generate_normals()
	surfTool.generate_tangents()
	surfTool.index()
	surfTool.commit(new_mesh)
	set_mesh(new_mesh)

func _ready():
	create_mesh()