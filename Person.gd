extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var per_tick_hunger = 0.05
var per_tick_shopping = 0.001
var per_tick_work = 0.002

class_name Person

var rng = RandomNumberGenerator.new()

onready var path: Path2D = get_parent()
onready var game_manager: Node = get_parent().get_parent()
onready var demand_manager: Node = game_manager.get_node("DemandManager")
onready var top_layer: SkylineLayer = game_manager.get_node("LayerArray")
onready var skyrm: SkyRenderManager = game_manager.get_node("SkyRenderManager")
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	print(name, " added")
	goal_timer = Timer.new()
	goal_timer.one_shot = true
	goal_timer.wait_time = 30
	goal_timer.connect("timeout",self,"_unhide_person")
	add_child(goal_timer)
	_unhide_person()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	curr_x = path.curve.interpolate_baked(offset)[0]
	walk_step(delta)
	tick_needs(delta)
	var demand_below = max(0,0.5-current_happiness)*2
	var demand_above = max(0,current_happiness - 0.5)*2
	modulate = Color(0.5*demand_below,0.5*demand_above,0.2*max(demand_below,demand_above))

var dir: int = 1;

var happiness_spread = 1
onready var current_happiness: float = 0.5

enum GOAL{
	NONE,
	HOME,
	WORK,
	FOOD,
	RETAIL
}

var GOAL_NAMES = ["NONE", "HOME", "WORK", "FOOD", "RETAIL"]

var home: BuildingInstance
var work: BuildingInstance
var work_target: BuildingInstance
var is_child = false
var current_goal
var goal_timer
var goal_pos
var waiting = false
var curr_x = 0
var worklist = [] #once again, bad but it will work

export (float, 1, 1200) var walkspeed_pps

# needs
var hunger = 0
var occupation = 0
var shopping = 0

func tick_needs(delta):
	if current_happiness <= 0:
		current_happiness = 0
	elif current_happiness >= 1:
		current_happiness = 1
	if hunger <= 1:
		hunger += delta * per_tick_hunger
	else:
		hunger = 1
	if shopping <= 1:
		shopping += delta * per_tick_shopping
	else:
		shopping = 1
	if occupation <= 1:
		occupation += delta * per_tick_work
	else:
		occupation = 1
	# todo do boundsing
	# todo the rest of the needs

func find_next_goal():
	goal_timer.wait_time = rng.randf_range(12, 33)
	match current_goal:
		GOAL.NONE:
			goal_pos = home.get_left()	
		GOAL.HOME:
			goal_pos = home.get_left()
		GOAL.WORK:
			if work != null:
				goal_timer.wait_time = rng.randf_range(4, 6)
				goal_pos = work.get_left()
			elif work_target != null:
				goal_timer.wait_time = rng.randf_range(4, 6)
				goal_pos = work_target.get_left()
			else:
				try_to_find_work()
		GOAL.FOOD:
			var foodlist = []
			for i in game_manager.layers:
				#print(i.find_building_before(curr_x, BUILDING.TYPE.FOOD))
				#offset
				if i.find_building_before(top_layer.get_x_value_at_offset(offset), BUILDING.TYPE.FOOD) >= 0:
					#print(i.building_list[i.find_building_before(curr_x, BUILDING.TYPE.FOOD)][0])
					foodlist.append(i.building_list[i.find_building_before(top_layer.get_x_value_at_offset(offset), BUILDING.TYPE.FOOD)][0])
			if len(foodlist) == 0:
				demand_manager.add_demand(BUILDING.TYPE.FOOD, 0.5)
			else:
				for f in foodlist:
					print("  ",f.definition.building_name)
				var rand_index: int = randi() % len(foodlist)
				goal_pos = foodlist[rand_index].get_left()
		GOAL.RETAIL:
			var retaillist = []
			for i in game_manager.layers:
				retaillist.append(i.find_building_before(top_layer.get_x_value_at_offset(offset), BUILDING.TYPE.RETAIL))
			if len(retaillist) == 0:
					demand_manager.add_demand(BUILDING.TYPE.RETAIL, 0.5)
			else:
				var rand_index: int = randi() % len(retaillist)
				goal_pos = retaillist[rand_index].get_left()
	goal_pos = top_layer.get_offset_value_at(goal_pos)
	print(name + " found goal at loc: ", goal_pos)
	print(name + " current pos: ", offset)
	
func try_to_find_work():
	worklist = []
	for i in game_manager.layers:
		for j in i.building_list:
			if j[0].definition.building_type == BUILDING.TYPE.WORK:
				worklist.append(j)
	if len(worklist) > 0:
		var rand_index: int = randi() % len(worklist)
		work_target = worklist[rand_index]
		goal_pos = work_target.get_left()
	else:
		demand_manager.add_demand(BUILDING.TYPE.WORK, 0.1)
		current_happiness *= 0.95
		goal_pos = home.get_left()

func decide_next_goal():
	var time_of_day = skyrm.world_time - floor(skyrm.world_time)
	if work != null:
		occupation *= 0.95
	current_goal = GOAL.HOME
	var current_goal_strength = 0
	if occupation > current_goal_strength:
		current_goal = GOAL.WORK
		current_goal_strength = occupation
	if hunger > current_goal_strength:
		current_goal = GOAL.FOOD
		current_goal_strength = hunger
	if shopping > current_goal_strength:
		current_goal = GOAL.RETAIL
		current_goal_strength = shopping
	if time_of_day < 0.25 or time_of_day > .75:
		current_goal = GOAL.HOME
		current_goal_strength = 1.1
	print(name + " decided goal: ", GOAL_NAMES[current_goal])
	find_next_goal()

func walk_step(delta):
	if goal_pos == null:
		decide_next_goal()
	if self.visible and (goal_pos != null): #TODO: and !paused
		if (offset > goal_pos):
			dir = -1
		else:
			dir = 1
		var dist = dir*walkspeed_pps*delta
		#print(offset)
		set_offset(offset+dist)
		if abs( goal_pos - offset ) < 10:
			self.visible = false
			print(name + " found goal: ", GOAL_NAMES[current_goal], " at ",offset)
			goal_timer.start()
		# TODO: make it if they find work they get assigned to the work and stuff
		else:
			if current_goal == GOAL.FOOD:
				demand_manager.add_demand(BUILDING.TYPE.FOOD, 0.03)
				current_happiness *= 0.97
			elif current_goal == GOAL.RETAIL:
				demand_manager.add_demand(BUILDING.TYPE.RETAIL, 0.06)
		update_happiness(10)
		current_happiness *= 0.9995

func _unhide_person():
	print("unhiding")
	if current_goal == GOAL.FOOD:
		hunger = 0
	if current_goal == GOAL.RETAIL:
		shopping = 0
	current_happiness *= 2
	decide_next_goal()
	self.visible = true

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
