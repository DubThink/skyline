extends Node2D

# This file is for a single layer of the skyline

var building_list = [] # array of tuples of [building_instance, x_pos, footprint]
var y_value = 270 # TODO; actually probably get curve height at position
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_y_value():
	return y_value

func add_building(building_inst, x_position, footprint):
	# Check if there is anything blocking the footprint, return false if so
	var placement_index = 0
	var before_idx = find_building_before(x_position)
	var after_idx = before_idx + 1# find_building_after(x_position)#before_idx + 1
	print("before idx %d, after idx %d" % [before_idx, after_idx])
	# TODO Rejig this so it doesn't assume that we're dealing with the bottom left corner
	var new_l = x_position
	var new_r = x_position + footprint
	if before_idx >= 0 and before_idx < building_list.size(): # validity check
		var before_r = building_list[before_idx][1] + building_list[before_idx][2]
		if new_l < before_r:
			# overlap with before building
			print("overlap with before building")
			return false
	if after_idx >= 0 and after_idx < building_list.size(): # validity check
		var after_l = building_list[after_idx][1]
		if new_l < after_l and new_r > after_l:
			# overlap with after building
			print("overlap with after building")
			return false
	print("Inserting new building at index %d" % after_idx)
	building_list.insert(after_idx, [instance_building(building_inst, x_position), x_position, footprint])
	print("number of existing buildings: %d" % building_list.size())
	var s = ""
	for i in range(0, building_list.size()):
		s += "[" + str(building_list[i][1]) + "," + str(building_list[i][2]) + "],"
	print(s)
	return true

func find_building_before(position):
	if(building_list.size() == 0):
		return -1
	var index = building_list.size()-1
	for i in range(0, building_list.size()):
		if building_list[i][1] > position:
			index = i-1
			break
	return index
	
func find_building_after(position):
	if(building_list.size() == 0):
		return 0
	var index = building_list.size()
	for i in range(0, building_list.size()):
		if building_list[i][1] > position:
			index = i
			break
	return index
	
func instance_building(inst, x_pos):
#	var building_inst = scene.instance()
	var building_inst = inst.duplicate()
	add_child(building_inst)
	building_inst.position = Vector2(x_pos, y_value)
	return building_inst
	
func display_preview(inst, x_position):
	var before_idx = find_building_before(x_position)
	var after_idx = before_idx + 1# find_building_after(x_position)#before_idx + 1
	var new_l = x_position
	var new_r = x_position + inst.get_footprint()
	var sprite : Sprite = inst.get_node("Sprite")
	sprite.modulate = Color(1,1,1)
	if before_idx >= 0 and before_idx < building_list.size(): # validity check
		var before_r = building_list[before_idx][1] + building_list[before_idx][2]
		if new_l < before_r:
			# overlap with before building
#			print("overlap with before building")
			sprite.modulate = Color(1,0,0)
	if after_idx >= 0 and after_idx < building_list.size(): # validity check
		var after_l = building_list[after_idx][1]
		if new_l < after_l and new_r > after_l:
			# overlap with after building
#			print("overlap with after building")
			sprite.modulate = Color(1,0,0)
	inst.position.x = x_position
	inst.position.y = y_value
	inst.show()
