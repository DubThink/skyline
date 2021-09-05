extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name BuildingFactory
var building_defs: Array

var sky_render_manager: SkyRenderManager
# Called when the node enters the scene tree for the first time.
func _ready():
	sky_render_manager = get_parent().get_node("SkyRenderManager")
	pass # Replace with function body.


func add_building_definition(definition: BuildingDefinition):
	assert(not definition in building_defs)
	building_defs.append(definition)
	

func create_building(definition: BuildingDefinition):
	var testInstance = BuildingInstance.new(definition, sky_render_manager)
	return testInstance
	# todo more binding here
	
	

var hasRun = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	if not hasRun:
#		# TODO instead call BuildingManager or whatever David writes
#		create_building(building_defs[0])
#		add_child(null)
#	hasRun = true
