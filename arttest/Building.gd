extends Polygon2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


class_name BuildingDefinition
export (String) var building_name;
export (BUILDING.TYPE, FLAGS ) var building_type;
export (BUILDING.LAYER) var layer;
export (int, 0, 50) var person_capacity;

var n_residents = 0
var average_happiness = 0

#var sr_manager = preload("res://arttest/SkyRenderManager.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
#	var n = get_node(".")
#	print()
#	var building_mat = sr_manager
#	print(sr_manager)
#	breakpoint
	pass
#


func initialize(var building_mat: ShaderMaterial):
	print("init",building_mat)
	for child in get_children():
		if child is ColorRect:
			child.set_material(building_mat)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
