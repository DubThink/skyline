extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name BuildingFactory
var rid: RuntimeImportData

var sky_render_manager: SkyRenderManager
# Called when the node enters the scene tree for the first time.
func _ready():
	rid = ResourceLoader.load("res://rid1.res","",true)
	sky_render_manager = get_parent().get_node("SkyRenderManager")
	pass # Replace with function body.
	

func create_building(definition: BuildingBakedDefinition):
	var testInstance = BuildingInstance.new(definition, sky_render_manager)
	testInstance.z_index = 10 - definition.layer*2+1
	testInstance.z_as_relative=false
	return testInstance
	# todo more binding here
	
func get_building_def():
	return rid.building_definitions[randi()%len(rid.building_definitions)]

var hasRun = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	if not hasRun:
#		# TODO instead call BuildingManager or whatever David writes
#		create_building(building_defs[0])
#		add_child(null)
#	hasRun = true

func visualize_food():
	pass

func visualize_happiness():
	pass
	
func visualize_retail():
	pass
	
func visualize_work():
	pass

func visualize_school():
	pass
		
func is_visualizing():
	pass
	
func stop_visualizing():
	pass
