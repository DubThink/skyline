extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



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

var happiness_spread = 1
onready var current_happiness: float = 0.5

enum GOAL{
	NONE,
	HOME,
	WORK,
	FOOD,
	HEALTH
}

var home: BuildingInstance
var work: BuildingInstance
var is_child = false
var current_goal
var goal_timer
var goal_pos = 0

export (float, 1, 400) var walkspeed_pps

# needs
var hunger = 0
var occupation = 0
var medical = 0

func tick_needs(delta):
	hunger+=delta*0.003
	# todo do boundsing
	# todo the rest of the needs

func decide_next_goal():
	var time_of_day = SkyRenderManager.worldtime % SkyRenderManager.SECONDS_PER_DAY
	current_goal = GOAL.NONE
	var current_goal_strength = 0
	if occupation > current_goal_strength:
		current_goal = GOAL.WORK
		current_goal_strength = occupation
	if hunger > current_goal_strength:
		current_goal = GOAL.FOOD
		current_goal_strength = hunger
	if time_of_day < 0.25 or time_of_day > .65:
		current_goal = GOAL.HOME
		current_goal_strength = 1.1
	if medical > current_goal_strength:
		current_goal = GOAL.HEALTH
		current_goal_strength = medical
	
func find_next_goal():
	match current_goal:
		GOAL.HOME:
			goal_pos = home.offset
		GOAL.WORK:
			goal_pos = work.offset
		GOAL.FOOD:
			goal_pos = 0 #TODO: find the things
		GOAL.HEALTH:
			goal_pos = 0 #TODO: find the things

func walk_step(delta):
	dir = -1 if offset > goal_pos else 1
	var dist = dir*walkspeed_pps*delta
	#print(offset)
	set_offset(offset+dist)
	#if abs(goal_pos-offset)<10:
		# go invis
	#	goal_timer = new timer(60)

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
