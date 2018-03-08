extends Spatial

var Chunk = preload("TerrainChunk.tscn")

export(Material) var cell_material = preload("TerrainCell.material")

signal create_chunk(center)

export(int) var chunks_radius = 4
export(int) var radius = 4
export(Vector2) var visibility_radius = Vector2(38,26)

export(int) var chunks_alive_radius = 6

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)
export(NodePath) var camera_node
onready var camera = get_node(camera_node)

export(float, 0, 1) var cell_grid_alpha = 0.4

var chunks = {}

onready var game_space = get_node("/root/GameSpace")

func _ready():
	cell_material.set_shader_param("terrain_height_scale", world_data.TERRAIN_HEIGHT_SCALE)
	cell_material.set_shader_param("stone_min_angle", world_data.stone_min_angle)
	cell_material.set_shader_param("snow_height", world_data.snow_height)
	cell_material.set_shader_param("gravel_height", world_data.gravel_height)
	cell_material.set_shader_param("grass_height", world_data.grass_height)
	cell_material.set_shader_param("sand_height", world_data.sand_height)
	cell_material.set_shader_param("water_height", world_data.water_height)
	update_chunks(Vector2())

func show_grid():
	cell_material.set_shader_param("mask_weight", cell_grid_alpha)

func hide_grid():
	cell_material.set_shader_param("mask_weight", 0.0)

func update_chunks(center):
	for cube in game_space.cube_range(game_space.offset_to_cube(center), chunks_radius):
		var pos = cube * radius
		var chunk_center = game_space.cube_to_offset(Vector3(
			pos.z, pos.y, pos.x
		))
		if not chunks.has(chunk_center):
			add_chunk(chunk_center)

func add_chunk(center):
	chunks[center] = Chunk.instance()
	chunks[center].cell_material = cell_material
	chunks[center].world_data = world_data
	chunks[center].center = center
	chunks[center].radius = radius
	chunks[center].hide()
	add_child(chunks[center])

func update(cam_game_pos):
	#update_chunks(cam_game_pos)
	for center in chunks.keys():
		var delta = center - cam_game_pos
		if delta.length() <= visibility_radius.length():
			chunks[center].show()
		#elif delta.length() > chunks_alive_radius:
		#	remove_chunk(center)
		else:
			chunks[center].hide()
	
func remove_chunk(center):
	print("remove_chunk ", center)
	remove_child(chunks[center])
	chunks[center].queue_free()
	chunks.erase(center)

func _on_GameCamera_moved( target_position, camera_y_angle ):
	var cam_game_pos = world_data.get_game_pos(camera.target_position)
	update(cam_game_pos)