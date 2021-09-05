extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name BuildingInstance

var definition: BuildingDefinition
var Random

func _init(var _definition: BuildingDefinition, var srm: SkyRenderManager):
	definition = _definition
	set_texture(load("res://placeholder_building.png"))
	set_material(srm.instance_and_track_building_shader())
	get_material().set_shader_param("WINDOW_OFFSET", randf())
	
	# TODO set up render init
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_tint(var c: Color):
	get_material().set_shader_param("override_tint_color",c)
	
func clear_tint():
	get_material().set_shader_param("override_tint_color",Color(0,0,0,0))
	
func get_footprint():
	return 174 #texture.get_width()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
