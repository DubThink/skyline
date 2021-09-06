extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var terrain
var Person = preload("res://Person.tscn")
# Called when 
# the node enters the scene tree for the first time.
func _ready():
	terrain = get_parent().get_node("Terrain")
	assert(terrain)
	print(terrain)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randf() <0.05:
		add_person(0)
	pass


func add_person(var hpos):
	# todo actually set up the person with whatever DEETs they need
	var _person = Person.instance()
	terrain.add_child(_person)
	_person.add_to_group("people")
	
