extends Panel

var available_buildings = [] # : BuildingInstance # normal arrays cannot be type hinted
var buttons = []
var building_factory: BuildingFactory
var skyline
var last_removed = -1
onready var exit_menu = get_parent().get_parent().get_node("GuiLayer/ExitMenu")
onready var starter = get_parent().get_parent().get_node("Startup")

func _ready():
	skyline = get_parent().get_parent()
	building_factory = skyline.get_node("BuildingFactory")
	buttons.append(get_node("Button"))
	buttons.append(get_node("Button2"))
	buttons.append(get_node("Button3"))
	buttons.append(get_node("Button4"))
	for i in range(0, buttons.size()):
		buttons[i].connect("pressed", self, "on_click", [i])
		available_buildings.append(null)
	if starter.dev_mode:
		for button in buttons:
			var self_mod : Color = button.self_modulate
			self_mod.a = 1
			button.self_modulate = self_mod

#TODO build a wrapper for this for sim API
func add_available_building(index):
#	print("[dock] adding new building")
	var inst = building_factory.create_building(building_factory.get_building_def())
	available_buildings[index] = inst
	visualize_building_on_button(index)

func add_building_by_demand(index, inst):
#	print("[dock] adding new building by demand")
	available_buildings[index] = inst
	visualize_building_on_button(index)

func add_specific_building(inst):
	#asserts here
	assert(last_removed != -1 and available_buildings[last_removed] == null)
#	inst.get_parent().remove_child(inst)
	available_buildings[last_removed] = inst
	visualize_building_on_button(last_removed)
#	last_removed = -1

func visualize_last_removed():
	visualize_building_on_button(last_removed)

func on_click(index):
#	print("on_click for %d, %d available buildings" % [index, available_buildings.size()])
	if (not exit_menu.visible) and available_buildings.size() > index and available_buildings[index] != null:
#		print("[dock] button %d is occupied" % index)
		var building = available_buildings[index]
		building.set_scale(Vector2(1,1))
		building.get_parent().remove_child(building)
		skyline.select_building(building)
#		available_buildings[index] = null
#		free_selected_slot()
		last_removed = index
#		add_specific_building(building_factory.create_building(building_factory.get_building_def())) # what is this
	elif available_buildings.size() <= index:
		print("[dock] button %d is empty" % index)
	pass

func visualize_building_on_button(index):
#	print("[dock] visualizing building on button %d" % index)
	assert(index < available_buildings.size() and index >= 0)
	buttons[index].add_child(available_buildings[index])
	#TODO replace this with get_height
	var building_height = available_buildings[index].texture.get_height()
	var ratio = buttons[index].get_rect().size.y / building_height
	available_buildings[index].set_scale(Vector2(ratio,ratio))
	available_buildings[index].set_position(Vector2(buttons[index].get_rect().size.x/2,buttons[index].get_rect().size.y*17/20))
	

func get_free_slots():
	var slots = []
	for i in range(buttons.size()):
		slots.append(check_slot_free(i))
	return slots

func check_slot_free(index):
#	if index == last_removed:
#		return false
	return index < available_buildings.size() and available_buildings[index] == null

func num_slots():
	return buttons.size()
	
func free_selected_slot():
	available_buildings[last_removed] = null
	
func debug_buttons():
	if starter.dev_mode:
		for i in range(buttons.size()):
			buttons[i].text = str(available_buildings[i])
		
func _process(delta):
	debug_buttons()
