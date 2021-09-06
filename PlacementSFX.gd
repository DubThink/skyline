extends AudioStreamPlayer

onready var skyline = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	skyline.connect("placed_building", self, "on_building_placed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_building_placed(position):
	play()
