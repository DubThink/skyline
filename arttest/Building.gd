extends Polygon2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


class_name BuildingDefinition
export (BUILDING.TYPE, FLAGS ) var building_type;
export (BUILDING.LAYER) var layer;
export (int, 0, 50) var person_capacity;
export (bool) var no_export;

#var sr_manager = preload("res://arttest/SkyRenderManager.gd")
var bounds: Rect2;

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

func calculate_bounds(var offset):
	var pg = get_polygon()
	bounds = Rect2(pg[0].x,pg[0].y,0,0)
	for p in pg:
		bounds = bounds.expand(p)
	print("Bounds pre offset:",bounds)
	print("offset:",offset)
	bounds.position+=offset;
	print("Bounds post offset:",bounds)	
	return bounds
