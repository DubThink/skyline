extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var hasRun=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hasRun:
		return
	hasRun = true
	var xpos = 200
	var bf = get_parent().get_node("BuildingFactory")
	for bd in bf.rid.building_definitions:
		var cr = ColorRect.new()
		cr.rect_size = Vector2(40,40)
		add_child(cr)
		cr.set_position(Vector2(xpos,200))
	
		#bf.rid.building_definitions
		var b = bf.create_building(bd)
		add_child(b)
		b.set_position(xpos,200)
		xpos+=300
