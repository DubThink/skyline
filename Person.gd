extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var happiness_spread = 1
onready var current_happiness: float = 0.5
var home: BuildingInstance

class_name Person

onready var path: Path2D = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	walk_step(delta)
	pass

var dir: int = 1;

export (float, 1, 400) var walkspeed_pps

func walk_step(delta):
	var dist = dir*walkspeed_pps*delta
	#print(offset)
	set_offset(offset+dist)
	
func find_neighbors(dist):
	var all_people = get_tree().get_nodes_in_group("people")
	var neighbors = []
	for i in all_people:
		if (i.name == name):
			pass
		if (abs(i.offset - offset) < dist):
			neighbors.append(i)
	return neighbors
	
func update_happiness(dist):
	var d_happiness = []
	var neighbors = find_neighbors(dist)
	if len(neighbors) == 0:
		return
	for i in neighbors:
		d_happiness.append(i.current_happiness - current_happiness)
	var happiness_adjust = 0
	var num_neighbors = 1.0/len(d_happiness)
	for i in d_happiness:
		happiness_adjust += i * num_neighbors
	current_happiness += 0.5 * happiness_adjust * happiness_spread
	return
