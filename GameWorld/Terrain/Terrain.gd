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
	var cam_game_pos = world_data.get_game_pos(camera.target_position)
	var cam_chunk_pos = Vector2()
	for pos in world_data.get_cells_in_radius(cam_chunk_pos, chunks_radius):
		add_chunk(Vector2(
			pos.y * 2 * radius + radius * (int(abs(pos.x)) % 2),
			(pos.x * 3 * radius) / 2
		))
	update()

func update():
	var cam_game_pos = world_data.get_game_pos(
		camera.target_position - Vector3(1,0,1) * camera.camera_offset
	)
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
	add_child(chunks[center])
	chunks[center].hide()

func _on_create_chunk( center ):
	if chunks.has(center): return
	add_chunk(center)
