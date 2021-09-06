extends Node2D

export (float) var starting_house_demand
export (float) var starting_food_demand
export (float) var starting_med_demand
export (float) var starting_edu_demand
export (float) var starting_work_demand

var cap_ratio = 25 #a number
var demand : PoolRealArray
onready var factory = get_parent().get_node("BuildingFactory")
onready var dock = get_parent().get_node("GuiLayer/MenuDock")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # MAKE SURE THIS IS THE ONLY TIME WE CALL THIS, OR ONLY CALL IT ONCE SOMEWHERE ELSE
	demand.append(starting_house_demand)
	demand.append(starting_food_demand)
	demand.append(starting_med_demand)
	demand.append(starting_edu_demand)
	demand.append(starting_work_demand)

func add_demand(type, amount):
	assert(type >= 0 and type < BUILDING.TYPE._COUNT)
	demand[type] += amount

func apply_demand_to_dock():
	var sizes = get_building_sizes_allowed_in_slot()
	var slots_free = dock.get_free_slots()
#	print("free slots: %s %s %s %s" % [slots_free[0], slots_free[1], slots_free[2], slots_free[3]])
	for i in range(4):#slots_free.size()):
		if slots_free[i]:
			print("slot %d was free" % i)
			var type = get_next_building_type()
#			print("sizes length %d, sizes[%d] length %d" % [sizes.size(), i, sizes[i].size()])
			var size_to_use = sizes[i][randi() % (sizes[i].size())]
			# generate a building of that type
			var def = factory.get_building_def()
			var inst = factory.create_building(def)
			# decrease demands by that much
			reduce_demand(def)
			# give it to the slot
			dock.add_building_by_demand(i, inst)

func get_building_sizes_allowed_in_slot():
	return [[BUILDING.LAYER.SMOL], 
	[BUILDING.LAYER.SMOL, BUILDING.LAYER.MEDIUM], 
	[BUILDING.LAYER.MEDIUM, BUILDING.LAYER.LARGE], 
	[BUILDING.LAYER.LARGE, BUILDING.LAYER.HIGH_RISE]]
	
func get_next_building_type():
	var cumulative = [0] #dummy value
	for i in range(BUILDING.TYPE._COUNT):
		cumulative.append(cumulative[i] + demand[i])
	cumulative.remove(0) #remove dummy
	var r = randf() * cumulative[-1] #last emelent is total demand
	for i in range(BUILDING.TYPE._COUNT):
		if r <= cumulative[i]:
			return i
	return BUILDING.TYPE.WORK #edge case for top end?

func capacity_to_demand(capacity):
	return 1#capacity / cap_ratio

func sizelayer_to_demand(layer):
	return layer+1

func reduce_demand(definition: BuildingBakedDefinition):
	print("building of type %d had %d capacity, was size %d" % [definition.building_type, definition.person_capacity, definition.layer])
	if definition.building_type & (1<<BUILDING.TYPE.HOUSE):
		reduce_demand_for(BUILDING.TYPE.HOUSE, capacity_to_demand(definition.person_capacity))
	if definition.building_type & (1<<BUILDING.TYPE.SCHOOL):
		reduce_demand_for(BUILDING.TYPE.SCHOOL, capacity_to_demand(definition.person_capacity))
	if definition.building_type & (1<<BUILDING.TYPE.WORK):
		reduce_demand_for(BUILDING.TYPE.WORK, capacity_to_demand(definition.person_capacity))
	if definition.building_type & (1<<BUILDING.TYPE.FOOD):
		reduce_demand_for(BUILDING.TYPE.FOOD, sizelayer_to_demand(definition.layer))
	if definition.building_type & (1<<BUILDING.TYPE.RETAIL):
		reduce_demand_for(BUILDING.TYPE.RETAIL, sizelayer_to_demand(definition.layer))
	
func reduce_demand_for(type, amount):
	print("reducing demand for %d by %f" % [type, amount])
	demand[type] -= amount
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	apply_demand_to_dock()
	display_demand_info_text()
#	pass

func display_demand_info_text():
	var label = get_node("CanvasLayer/Panel/Label")
	var text = ""
	text += "HOUSING: " + str(demand[BUILDING.TYPE.HOUSE]) + "\n"
	text += "FOOD:    " + str(demand[BUILDING.TYPE.FOOD]) + "\n"
	text += "RETAIL: " + str(demand[BUILDING.TYPE.RETAIL]) + "\n"
	text += "SCHOOL:  " + str(demand[BUILDING.TYPE.SCHOOL]) + "\n"
	text += "WORK:    " + str(demand[BUILDING.TYPE.WORK])
	label.text = text
