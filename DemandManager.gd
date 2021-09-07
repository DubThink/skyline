extends Node2D

export (float) var starting_house_demand
export (float) var starting_food_demand
export (float) var starting_med_demand
export (float) var starting_edu_demand
export (float) var starting_work_demand

export (float) var cap_ratio = 0.1 #a number
var demand : PoolRealArray
onready var factory = get_parent().get_node("BuildingFactory")
onready var dock = get_parent().get_node("GuiLayer/MenuDock")
onready var happiness_mgr = get_parent().get_node("HappinessManager")
var has_demanded = false
export (Array, float) var demand_reduction_for_size = [0.5, 1, 1.5, 3, 6]
export (float) var decay_amount = 0.04
export (float) var demand_min = 1

var type_names = ["HOUSE", "FOOD", "RETAIL", "SCHOOL", "WORK"]
var size_names = ["SMOL","MEDIUM","LARGE","HIGH_RISE","MONUMENT"]
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
	demand[type] += amount  * 1/max(1, demand[type] + 1)

func apply_demand_to_dock():
	var sizes = get_building_sizes_allowed_in_slot()
	var slots_free = dock.get_free_slots()
#	print("free slots: %s %s %s %s" % [slots_free[0], slots_free[1], slots_free[2], slots_free[3]])
	for i in range(slots_free.size()):
		if slots_free[i]:
			print("--\n[demand] slot %d was free" % i)
			var type = get_next_building_type()
			if type == -1:
				break
			print("[demand] had demand for %s, which has demand of %f" % [type_names[type], demand[type]])
#			print("sizes length %d, sizes[%d] length %d" % [sizes.size(), i, sizes[i].size()])
			var size_to_use = sizes[i][randi() % (sizes[i].size())]
			print("[demand] placing a building of size %s" % size_names[size_to_use])
			# TODO generate a building of that type
			print("[--] factory.get_building_def(%s, %s)" % [size_names[size_to_use], type_names[type]])
			var def = factory.get_building_def(size_to_use,type)
			print("[--] returned building: %s %d named %s" % [size_names[def.layer], def.building_type, def.building_name])
			var inst = factory.create_building(def)
			# decrease demands by that much
#			reduce_demand(def)
			# give it to the slot
			dock.add_building_by_demand(i, inst)

func get_building_sizes_allowed_in_slot():
	return [[BUILDING.LAYER.SMOL], 
	[BUILDING.LAYER.SMOL, BUILDING.LAYER.MEDIUM], 
	[BUILDING.LAYER.MEDIUM, BUILDING.LAYER.LARGE], 
	[BUILDING.LAYER.LARGE, BUILDING.LAYER.HIGH_RISE]]
	
func get_next_building_type():
	var cumulative = [0.0] #dummy value
	for i in range(BUILDING.TYPE._COUNT):
		var positive_demand = demand[i]
		if positive_demand < 0:
			positive_demand = 0
		cumulative.append(cumulative[i] + positive_demand)
	cumulative.remove(0) #remove dummy
	var r = randf() * cumulative[-1] #last emelent is total demand
	var type_of_demand = -1
	for i in range(BUILDING.TYPE._COUNT):
		if r <= cumulative[i]:
			type_of_demand = i
			break
	var s = "[demand] [get_next_building_type] cumulative array: ["
	for i in range(cumulative.size()):
		s += str(cumulative[i]) + ","
	s += "]"
	print(s)
	print("[demand] [get_next_building_type] r = %f, total demand %f, type chosen %d" % [r, cumulative[-1], type_of_demand])
	if(type_of_demand == -1):
		print("[demand] [get_next_building_type] type of demand never set?")
	if(demand[type_of_demand] <= 0):
		print("[demand] [get_next_building_type] desired type of demand was non-positive")
		return -1
	return type_of_demand

func capacity_to_demand(capacity):
	return capacity * cap_ratio

func sizelayer_to_demand(layer):
	return demand_reduction_for_size[layer]

func handle_demand_for_inst(inst):
	reduce_demand(inst.definition)

func reduce_demand(definition: BuildingBakedDefinition):
	print("[demand] reducing demand building of type %d had %d capacity, was size %s, with name %s" % [definition.building_type, definition.person_capacity, size_names[definition.layer], definition.building_name])
	if definition.building_type:
		if definition.has_type(BUILDING.TYPE.HOUSE):
			reduce_demand_for(BUILDING.TYPE.HOUSE, capacity_to_demand(definition.person_capacity))
		if definition.has_type(BUILDING.TYPE.SCHOOL):
			reduce_demand_for(BUILDING.TYPE.SCHOOL, capacity_to_demand(definition.person_capacity))
		if definition.has_type(BUILDING.TYPE.WORK):
			reduce_demand_for(BUILDING.TYPE.WORK, capacity_to_demand(definition.person_capacity))
		if definition.has_type(BUILDING.TYPE.FOOD):
			reduce_demand_for(BUILDING.TYPE.FOOD, sizelayer_to_demand(definition.layer))
		if definition.has_type(BUILDING.TYPE.RETAIL):
			reduce_demand_for(BUILDING.TYPE.RETAIL, sizelayer_to_demand(definition.layer))
	
func reduce_demand_for(type, amount):
	print("[demand] reducing demand for %s by %f" % [type_names[type], amount])
	demand[type] -= amount
	if(demand[type] < 0):
		demand[type] = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if not has_demanded:
	apply_demand_to_dock()
#		has_demanded = true
	display_demand_info_text()
	decay_demand(delta)
#	pass

func display_demand_info_text():
	var label = get_node("CanvasLayer/Panel/Label")
	var text = ""
	text += "HOUSING: " + str("%.1f" % demand[BUILDING.TYPE.HOUSE]) + "\n"
	text += "FOOD: " + str("%.1f" % demand[BUILDING.TYPE.FOOD]) + "\n"
	text += "RETAIL: " + str("%.1f" % demand[BUILDING.TYPE.RETAIL]) + "\n"
	text += "SCHOOL: " + str("%.1f" % demand[BUILDING.TYPE.SCHOOL]) + "\n"
	text += "WORK: " + str("%.1f" % demand[BUILDING.TYPE.WORK]) + "\n"
	text += "HAPPINESS: " + str("%.1f" % happiness_mgr.get_happiness_level())
	label.text = text

func decay_demand(delta):
	demand[BUILDING.TYPE.FOOD] -= (demand[BUILDING.TYPE.FOOD] * decay_amount)
	demand[BUILDING.TYPE.RETAIL] -= (demand[BUILDING.TYPE.RETAIL] * decay_amount)
	demand[BUILDING.TYPE.WORK] -= (demand[BUILDING.TYPE.WORK] * decay_amount)
	demand[BUILDING.TYPE.SCHOOL] -= (demand[BUILDING.TYPE.SCHOOL] * decay_amount)

func decay(type):
	var prev = demand[type]
	demand[type] -= (demand[type] * decay_amount)
	if demand[type] < demand_min:
		demand[type] = demand_min
	
