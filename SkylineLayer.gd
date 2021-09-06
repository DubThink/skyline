extends Node2D

# This file is for a single layer of the skyline
class_name SkylineLayer
var building_list = [] # array of tuples of [building_instance, x_pos, footprint]
var y_value = 270 # TODO; actually probably get curve height at position
onready var terrain : Path2D = get_parent().get_node("Terrain")
onready var person_manager = get_parent().get_node("PersonManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_approx_y_value(x_pos):
	return y_value
	
func get_y_value_at(x_pos):
	var curve = terrain.get_curve()
	var est_point = curve.interpolate_baked(curve.get_closest_offset(Vector2(x_pos, y_value)))
	return est_point.y+terrain.position.y

func get_x_value_at_offset(offset):
	var curve = terrain.get_curve()
	var est_point = curve.interpolate_baked(offset)
	return est_point.x

func get_offset_value_at(x_pos):
	var curve = terrain.get_curve()
	return curve.get_closest_offset(Vector2(x_pos, y_value))


func add_building(building_inst: BuildingInstance, x_position):
	var footprint = building_inst.get_footprint()
	# Check if there is anything blocking the footprint, return false if so
	var placement_index = 0
	var before_idx = find_building_before(x_position)
	var after_idx = before_idx + 1# find_building_after(x_position)#before_idx + 1
#	print("before idx %d, after idx %d" % [before_idx, after_idx])
	# TODO Rejig this so it doesn't assume that we're dealing with the bottom left corner
	var new_l = x_position + building_inst.get_h_center()
	var new_r = x_position + footprint + building_inst.get_h_center()
	if before_idx >= 0 and before_idx < building_list.size(): # validity check
		var before_r = building_list[before_idx][1] + building_list[before_idx][2]
		if new_l < before_r:
			# overlap with before building
#			print("overlap with before building")
			return false
	if after_idx >= 0 and after_idx < building_list.size(): # validity check
		var after_l = building_list[after_idx][1]
		if new_l < after_l and new_r > after_l:
			# overlap with after building
#			print("overlap with after building")
			return false
#	print("Inserting new building at index %d" % after_idx)
	building_list.insert(after_idx, [instance_building(building_inst, x_position), x_position+ building_inst.get_h_center(), footprint])
	print("about to add people plz")
	if(building_inst.definition.has_type(BUILDING.TYPE.HOUSE)):
		print("is house")
		for i in range(building_inst.definition.person_capacity):
			person_manager.add_person(terrain.curve.get_closest_offset(Vector2(x_position, get_approx_y_value(x_position))), building_inst)
#	print("number of existing buildings: %d" % building_list.size())
	var s = ""
	for i in range(0, building_list.size()):
		s += "[" + str(building_list[i][1]) + "," + str(building_list[i][2]) + "],"
	print(s)
	return true

func find_building_before(position, required_type=null):
	if(building_list.size() == 0):
		return -1
	var index = building_list.size()-1
	for i in range(0, building_list.size()):
		if building_list[i][1] > position and building_list[i][0].get_definition().has_type(required_type):
			index = i-1
			break
	return index
	
func find_building_after(position, required_type=null):
	if(building_list.size() == 0):
		return 0
	var index = building_list.size()
	for i in range(0, building_list.size()):
		if building_list[i][1] > position and building_list[i][0].get_definition().has_type(required_type):
			index = i
			break
	return index
	
func instance_building(inst, x_pos):
#	var building_inst = scene.instance()
	# TODO $AWELSH I hacked this it needs to be fixed !!
#	var building_inst = inst.duplicate()
	inst.get_parent().remove_child(inst)
	add_child(inst)
	inst.set_position(Vector2(x_pos, get_y_value_at(x_pos)))
	return inst
	
func display_preview(inst, x_position):
	var before_idx = find_building_before(x_position)
	var after_idx = before_idx + 1# find_building_after(x_position)#before_idx + 1
	var new_l = x_position + inst.get_h_center()
	var new_r = x_position + inst.get_footprint() + inst.get_h_center()
	 
	inst.clear_tint()
	if before_idx >= 0 and before_idx < building_list.size(): # validity check
		var before_r = building_list[before_idx][1] + building_list[before_idx][2]
		if new_l < before_r:
			# overlap with before building
#			print("overlap with before building")
			inst.set_tint(Color(1,0,0))
	if after_idx >= 0 and after_idx < building_list.size(): # validity check
		var after_l = building_list[after_idx][1]
		if new_l < after_l and new_r > after_l:
			# overlap with after building
#			print("overlap with after building")
			inst.set_tint(Color(1,0,0))
	inst.set_position(Vector2(x_position, get_y_value_at(x_position)))
	inst.show()
	
func has_buildings():
	return building_list.size() > 0
