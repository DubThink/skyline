extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var layers = []
var height_allowance = 100
var selected_building: BuildingInstance

var building_factory: BuildingFactory

# Called when the node enters the scene tree for the first time.
func _ready():
	layers.append(get_node("LayerArray"))
	layers.append(get_node("LayerArray2"))
	layers.append(get_node("LayerArray3"))
	building_factory = get_node("BuildingFactory")
	# this stuff should actually happen in whatever "buttons" we make for 
	# selection, as well as in the place where the "buttons" are instantiated.
	
	selected_building = building_factory.create_building(null) #load("res://FakeBuilding.tscn").instance()
	add_child(selected_building)
#	selected_building.hide()

func _process(delta):
	var mouse_pos = get_node("Camera2D").get_global_mouse_position()
	var mouse_in_allowance = abs(layers[0].get_y_value() - mouse_pos.y) < height_allowance
	if mouse_in_allowance and not selected_building == null:
		layers[0].display_preview(selected_building, mouse_pos.x)
	elif not selected_building == null:
		selected_building.set_position(mouse_pos)
#		selected_building.hide()
	if Input.is_action_just_pressed("ui_click"):
		if mouse_in_allowance and not selected_building == null:
			# TODO replace with actual building stuff
			if layers[0].add_building(selected_building, mouse_pos.x):
				selected_building = building_factory.create_building(null)
				add_child(selected_building)
	#TODO smooth these out and make it nice :)
	if Input.is_action_just_released("ui_zoom_in"):
		# zoom in
		var cam = get_node("Camera2D")
		cam.zoom -= Vector2(0.1, 0.1)
		cam.position = lerp(cam.position, Vector2(mouse_pos.x, cam.position.y), 0.1)
	if Input.is_action_just_released("ui_zoom_out"):
		# zoom out
		var cam = get_node("Camera2D")
		cam.zoom += Vector2(0.1, 0.1)
		cam.position = lerp(cam.position, Vector2(mouse_pos.x, cam.position.y), 0.1)
	if Input.is_action_just_pressed("ui_right_click"):
		# get rid of current thing
		# actually just put it back at the bottom?
		pass

func select_building(inst):
	selected_building = inst
