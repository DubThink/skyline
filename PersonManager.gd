extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng = RandomNumberGenerator.new()

var terrain
var Person = preload("res://Person.tscn")
# Called when 
# the node enters the scene tree for the first time.
func _ready():
	terrain = get_parent().get_node("Terrain")
	rng.randomize()
	assert(terrain)
	print(terrain)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_person(var hpos, var home):
	# todo actually set up the person with whatever DEETs they need
	var _person = Person.instance()
	_person.home = home
	_person.offset = hpos
	_person.current_goal = home.get_left()
	_person.add_to_group("people")
	var t = Timer.new()
	t.one_shot = true
	t.wait_time = rng.randf_range(0.5, 5)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	print("Added person: " + _person.name + " at " + str(_person.offset))
	terrain.add_child(_person)
	t.queue_free()	


