extends Node

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

func move_actor(actor, pos):
	objects[actor.game_position] = null
	objects[pos] = actor
	emit_signal("actor_moved", actor, pos)

func _on_GameWorld_wagon( pos ):
	var wagon = Wagon.instance()
	wagon.game_position = pos
	objects[pos] = wagon
	emit_signal("actor_placed", wagon, pos)

func _on_GameWorld_select(pos):
	if objects.has(pos):
		emit_signal("selected", pos)
	else:
		emit_signal("deselected")