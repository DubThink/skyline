extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
class_name Person


onready var path: Path2D = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	walk_step(delta)
	pass

var dir: int = 1;

export (float, 1, 400) var walkspeed_pps

func walk_step(delta):
	var dist = dir*walkspeed_pps*delta
	print(offset)
	set_offset(offset+dist)
	
