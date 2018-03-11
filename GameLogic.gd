extends Node

export(NodePath) var selection_node
onready var selection = get_node(selection_node)
onready var pathfinder = selection.get_node("Pathfinder")
export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

var Wagon = preload("res://GameWorld/Units/Wagon.tscn")
var House = preload("res://GameWorld/Places/House.tscn")

signal change_mode(mode)
signal selected(object)

enum Mode {MODE_IDLE,MODE_SELECT,MODE_PLACE,MODE_MOVE}
export(Mode) var mode = MODE_IDLE setget set_mode

func set_mode(val):
	mode = val
	emit_signal("change_mode", mode)

export(NodePath) var places_node
onready var places = get_node(places_node)
export(NodePath) var units_node
onready var units = get_node(units_node)

enum ObjectType {OBJECT_UNIT, OBJECT_PLACE}

var selected = null
var selected_type = OBJECT_UNIT

func select(object, type):
	selected = object
	selected_type = type
	emit_signal("selected", object)
	
export(ObjectType) var place_mode = OBJECT_UNIT
var PlaceObjectClass = Wagon

func set_place_mode(pmode, ObjectClass):
	place_mode = pmode
	PlaceObjectClass = ObjectClass

func _on_GameWorld_select(pos):
	match(mode):
		MODE_SELECT:
			var sel = units.select(pos)
			if sel != null:
				select(sel, OBJECT_UNIT)
				return
			sel = places.select(pos)
			if sel != null:
				print("select ",sel)
				select(sel, OBJECT_PLACE)
				return
			select(null,null)
		MODE_PLACE:
			if units.map.has(pos) or places.map.has(pos):
				return
			match(place_mode):
				OBJECT_UNIT:
					units.place_unit(PlaceObjectClass, pos)
					var unit = units.select(pos)
					select(unit, OBJECT_UNIT if unit else null)
				OBJECT_PLACE:
					places.place_place(PlaceObjectClass, pos)
					var place = places.select(pos)
					select(place, OBJECT_PLACE if place else null)
		MODE_MOVE:
			if (selected_type == OBJECT_UNIT) and selected:
				units.move_unit(selected, pos)
				set_mode(MODE_SELECT)
				select(units.select(pos), OBJECT_UNIT)

func _on_GameWorld_change_mode(mode):
	if mode==MODE_MOVE and selected_type!=OBJECT_UNIT: return
	set_mode(mode)

func _on_GameWorld_change_place_mode(mode, ObjectClass):
	set_place_mode(mode, ObjectClass)
