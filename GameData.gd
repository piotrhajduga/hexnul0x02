extends Node

export(NodePath) var selection_node
onready var selection = get_node(selection_node)
onready var pathfinder = selection.get_node("Pathfinder")
export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

signal actor_placed(actor, pos)
signal actor_moved(actor, pos)
signal selected(pos)

var Wagon = preload("res://GameWorld/Unit/Unit.tscn")

var rivers = {}
var roads = {}
var buildings = {}
var objects = {}
var actors = {}

var selected = null setget select

func select(pos):
	selected = pos
	emit_signal("selected", pos)

func _on_GameWorld_wagon( pos ):
	if world_data.is_passable(pos):
		var wagon = Wagon.instance()
		wagon.world_data = world_data
		wagon.connect("moved", self, "_on_actor_moved")
		wagon.game_position = pos
		objects[pos] = wagon
		emit_signal("actor_placed", wagon, pos)
		select(pos)

func _on_actor_moved(actor, from_pos):
	if from_pos == selected: select(null)
	objects.erase(from_pos)
	objects[actor.game_position] = actor
	emit_signal("actor_moved", actor, actor.game_position)

func _on_GameWorld_select(pos):
	if objects.has(pos):
		select(pos)
	else:
		select(null)

func _on_GameWorld_move( pos ):
	if selected == null:
		print("No selection!")
		return
	var actor = objects[selected]
	if actor:
		objects[selected].path = pathfinder.get_path(selected, pos)
		if not objects[selected].path.empty():
			select(null)
