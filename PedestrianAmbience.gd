extends AudioStreamPlayer2D

export (float, -80, 24) var min_db = 0 #at full zoom out
export (float, -80, 24) var max_db = 0 #at full zoom in

onready var cam : Camera2D = get_parent().get_node("Camera2D")
onready var skyline = get_parent()
var target_vol
var any_buildings_placed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	skyline.connect("placed_building", self, "on_building_placed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	volume_db = calc_target_vol()
	pass

func calc_target_vol():
	if not any_buildings_placed:
		return -80
	var zoom_pct = (cam.zoom.x - skyline.zoom_min) / (skyline.find_max_zoom().x - skyline.zoom_min)
	return lerp(max_db, min_db, zoom_pct)
	
func locate_center_and_move():
	var target = skyline.find_center()
	position = target
	
func on_building_placed(pos):
	locate_center_and_move()
	if not any_buildings_placed:
		any_buildings_placed = true
		volume_db = calc_target_vol()
		play()
	
