extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name BuildingInstance

var definition: BuildingBakedDefinition
var Random

func _init(var _definition: BuildingBakedDefinition, var srm: SkyRenderManager):
	definition = _definition
	set_texture(definition.src_tex)
#	set_texture(load("res://tmp_uvs.jpg"))
	set_material(srm.instance_and_track_building_shader())
	get_material().set_shader_param("WINDOW_OFFSET", randf())
	get_material().set_shader_param("layer",definition.layer)
	definition.get_residentialness()
	set_scale(Vector2(1,1))
	#get_material().set_shader_param("residentialness",definition.)
	# TODO set up render init
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_scale(var sc):
	scale = sc*definition.image_scale_factor
	print("scale of ",definition.building_name,": ",scale)

func set_position(var x, var y = null):
	if y:
		x = Vector2(x,y)
	var offset = Vector2(256,-256)
	#offset += definition.bounds.position
	#x.x-=definition.bounds.position.x
	#x.y-=definition.bounds.position.y
	position = x + offset*scale + definition.bounds.position

func set_position_left(var x, var y = null):
	if y:
		x = Vector2(x,y)
	var offset = Vector2(256,-256)
	#offset.y += definition.bounds.position.y
	#x.x-=definition.bounds.position.x
	#x.y-=definition.bounds.position.y
	position = x + offset*scale  + Vector2(0,definition.bounds.position.y)

func get_left():
	return position.x - (248+definition.bounds.position.x)*scale.x

func set_tint(var c: Color):
	get_material().set_shader_param("override_tint_color",c)
	
func clear_tint():
	get_material().set_shader_param("override_tint_color",Color(0,0,0,0))
	
func get_footprint():
	return definition.bounds.size.y #texture.get_width()

func get_definition():
	return definition

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
