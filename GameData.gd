extends Node

export(NodePath) var pathfinder_node
onready var pathfinder = get_node(pathfinder_node)
export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

signal actor_placed(actor, pos)
signal actor_moved(actor, pos)
signal selected(pos)
signal deselected()

var Wagon = preload("res://GameWorld/Unit/Unit.tscn")

var rivers = {}
var roads = {}
var buildings = {}
var objects = {}
var actors = {}

var selected = null setget select

func select(pos):
	selected = pos
	if selected == null:
		emit_signal("deselected")
	else:
		emit_signal("selected", pos)

func _on_GameWorld_wagon( pos ):
	if pathfinder.is_impassable(pos): return
	var wagon = Wagon.instance()
	wagon.pathfinder = pathfinder
	wagon.world_data = world_data
	wagon.connect("moved", self, "_on_actor_moved")
	wagon.game_position = pos
	objects[pos] = wagon
	emit_signal("actor_placed", wagon, pos)
	select(pos)

func _on_actor_moved(actor, from_pos):
	objects[from_pos] = null
	objects[actor.game_position] = actor
	emit_signal("actor_moved", actor, actor.game_position)

func _on_GameWorld_select(pos):
	if objects.has(pos):
		select(pos)

func _on_GameWorld_move( pos ):
	if selected == null:
		print("No selection!")
		return
	var actor = objects[selected]
	if actor:
		objects[selected].find_path(pos)
		select(null)
