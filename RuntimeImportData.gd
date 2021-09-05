extends Resource
export (Array, Resource) var building_definitions

class_name RuntimeImportData


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _init():
	building_definitions=[]
	pass # Replace with function body.

func add_building_definition(var def: BuildingBakedDefinition):
	assert(def)
	print(def)
	building_definitions.append(def)
	print(building_definitions)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
