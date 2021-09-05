extends Panel

var available_buildings = [] # : BuildingInstance # normal arrays cannot be type hinted
var buttons = []
var building_factory: BuildingFactory
var skyline
var last_removed = -1

func _ready():
	skyline = get_parent().get_parent()
	building_factory = skyline.get_node("BuildingFactory")
	buttons.append(get_node("Button"))
	buttons.append(get_node("Button2"))
	buttons.append(get_node("Button3"))
	buttons.append(get_node("Button4"))
	buttons.append(get_node("Button5"))
	buttons.append(get_node("Button6"))
	for i in range(0, buttons.size()):
		buttons[i].connect("pressed", self, "on_click", [i])
	add_available_building(0) #test
	add_available_building(1) #test

#TODO build a wrapper for this for sim API
func add_available_building(index):
	var inst = building_factory.create_building(null)
	available_buildings.append(inst)
	visualize_building_on_button(index)

func add_specific_building(inst):
	#asserts here
	assert(last_removed != -1 and available_buildings[last_removed] == null)
#	inst.get_parent().remove_child(inst)
	available_buildings[last_removed] = inst
	visualize_building_on_button(last_removed)
#	last_removed = -1

func on_click(index):
#	print("on_click for %d, %d available buildings" % [index, available_buildings.size()])
	if available_buildings.size() > index and available_buildings[index] != null:
#		print("had something in")
		var building = available_buildings[index]
		building.scale = Vector2(1,1)
		building.get_parent().remove_child(building)
		skyline.select_building(building)
		available_buildings[index] = null
		last_removed = index
	elif available_buildings.size() <= index:
		print("empty")
	pass

func visualize_building_on_button(index):
	assert(index < available_buildings.size() and index >= 0)
	buttons[index].add_child(available_buildings[index])
#	available_buildings[index].set_position(buttons[index].get_rect().position)
	available_buildings[index].set_position(Vector2(0,buttons[index].get_rect().size.y))
	#TODO replace this with get_height
	var building_height = available_buildings[index].texture.get_height()
	var ratio = buttons[index].get_rect().size.y / building_height
	available_buildings[index].scale = Vector2(ratio,ratio)