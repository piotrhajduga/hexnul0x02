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

var selected = null setget select

func select(pos):
	selected = pos
	if selected == null:
		emit_signal("deselected")
	else:
		emit_signal("selected", pos)

func _on_GameWorld_wagon( pos ):
	var wagon = Wagon.instance()
	wagon.game_position = pos
	objects[pos] = wagon
	emit_signal("actor_placed", wagon, pos)
	select(pos)

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
		objects[selected] = null
		actor.game_position = pos
		objects[pos] = actor
		emit_signal("actor_moved", actor, pos)
		select(pos)
