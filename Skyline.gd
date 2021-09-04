extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var layers = []
var height_allowance = 100

var selected_building_type = load("res://FakeBuilding.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	layers.append(get_node("LayerArray"))
	layers.append(get_node("LayerArray2"))
	layers.append(get_node("LayerArray3"))

func _process(delta):
	if Input.is_action_just_pressed("ui_click"):
		var mouse_pos = get_node("Camera2D").get_global_mouse_position()
		if abs(layers[0].get_y_value() - mouse_pos.y) < height_allowance:
			# TODO replace with actual building stuff
	#		var building_scene = load("res://FakeBuilding.tscn")
			var building = selected_building_type.instance()
	#		add_child(building)
	#		building.position = Vector2(mouse_pos.x, 100)
			layers[0].add_building(selected_building_type, mouse_pos.x, building.get_footprint())
			# do place a house if we've got one selected
	#TODO smooth these out and make it nice :)
	if Input.is_action_just_released("ui_zoom_in"):
		# zoom in
		var mouse_pos = get_node("Camera2D").get_global_mouse_position()
		var cam = get_node("Camera2D")
		cam.zoom -= Vector2(0.1, 0.1)
		cam.position = lerp(cam.position, Vector2(mouse_pos.x, cam.position.y), 0.1)
		print("zoom in")
		pass
	if Input.is_action_just_released("ui_zoom_out"):
		# zoom out
		var mouse_pos = get_node("Camera2D").get_global_mouse_position()
		var cam = get_node("Camera2D")
		cam.zoom += Vector2(0.1, 0.1)
		cam.position = lerp(cam.position, Vector2(mouse_pos.x, cam.position.y), 0.1)
		print("zoom out")
		pass
	pass
