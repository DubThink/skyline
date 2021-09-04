extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name BuildingInstance

var definition: BuildingDefinition

func _init(var _definition: BuildingDefinition, var srm: SkyRenderManager):
	definition = _definition
	set_size(Vector2(100,100))
	
	# TODO set up render init
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
