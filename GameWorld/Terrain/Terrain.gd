extends Spatial

var Chunk = preload("TerrainChunk.tscn")

signal create_chunk(center)

export(int) var chunks_radius = 12
export(int) var radius = 4
export(Vector2) var visibility_radius = Vector2(38,26)

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)
export(NodePath) var camera_node
onready var camera = get_node(camera_node)

var chunks = {}

func _ready():
	for pos in world_data.get_cells_in_radius(Vector2(), chunks_radius):
		add_chunk(Vector2(
			(2*radius+1)*pos.y + radius * (int(abs(pos.x))%2),
			(radius+2)*pos.x
		))

func update(cam_game_pos):
	for center in chunks.keys():
		var delta = center - cam_game_pos
		var angle = acos(Vector2(0,-1).dot(delta))
		if delta.length() <= visibility_radius.length():
			chunks[center].show()
		else:
			chunks[center].hide()

func add_chunk(center):
	chunks[center] = Chunk.instance()
	chunks[center].world_data = world_data
	chunks[center].center = center
	chunks[center].radius = radius
	chunks[center].hide()
	add_child(chunks[center])

func _on_create_chunk( center ):
	if chunks.has(center): return
	add_chunk(center)

func _on_GameCamera_moved( target_position, camera_y_angle ):
	var cam_game_pos = world_data.get_game_pos(
		camera.target_position - Vector3(1,0,1) * camera.camera_offset.rotated(Vector3(0,1,0), camera_y_angle)
	)
	update(cam_game_pos)
