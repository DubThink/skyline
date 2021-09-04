extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var bf = get_node("BuildingFactory")
	bf.add_building_definition(get_node("BuildingDefinition"))
	#bf.create_building(bf.buildingDefs[0])
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
