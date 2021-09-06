extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var layers = []
var height_allowance = 100
var selected_building: BuildingInstance

var target_cam_zoom
var target_cam_pos
var pct_zoom = 0.2 # maybe change to 0.3
onready var building_factory: BuildingFactory = get_node("BuildingFactory")
onready var cam : Camera2D = get_node("Camera2D")
onready var dock = get_node("GuiLayer/MenuDock")
var drag_origin

# Called when the node enters the scene tree for the first time.
func _ready():
	layers.append(get_node("LayerArray"))
	layers.append(get_node("LayerArray2"))
	layers.append(get_node("LayerArray3"))
	
	# this stuff should actually happen in whatever "buttons" we make for 
	# selection, as well as in the place where the "buttons" are instantiated.
	
	selected_building = null#building_factory.create_building(null) #load("res://FakeBuilding.tscn").instance()
#	add_child(selected_building)
	target_cam_zoom = cam.zoom
	target_cam_pos = cam.position
	
func update_cam():
	if cam.zoom != target_cam_zoom:
		cam.zoom = lerp(cam.zoom, target_cam_zoom, 0.05)
	if cam.position != target_cam_pos:
		cam.position = lerp(cam.position, target_cam_pos, 0.05)

func _process(delta):
	var mouse_pos = get_node("Camera2D").get_global_mouse_position()
	var mouse_in_allowance = abs(layers[0].get_approx_y_value(0) - mouse_pos.y) < height_allowance
	if mouse_in_allowance and not selected_building == null:
		layers[0].display_preview(selected_building, mouse_pos.x)
	elif not selected_building == null:
		selected_building.set_position(mouse_pos)
		selected_building.clear_tint()
	if Input.is_action_just_pressed("ui_click"):
		if mouse_in_allowance and not selected_building == null:
			# TODO replace with actual building stuff
			if layers[0].add_building(selected_building, mouse_pos.x):
				selected_building = null#building_factory.create_building(null)
				dock.free_selected_slot()
				#add_child(selected_building)
	#TODO smooth these out and make it nice :)
	if Input.is_action_just_released("ui_zoom_in"):
		target_cam_zoom = (cam.zoom - Vector2(pct_zoom, pct_zoom))
		var move_vec = (Vector2(mouse_pos.x, cam.position.y) - cam.position) * pct_zoom
		target_cam_pos = cam.position + move_vec
	if Input.is_action_just_released("ui_zoom_out"):
		var inverse_mouse_xpos = cam.get_viewport_rect().size.x - mouse_pos.x
		target_cam_zoom = (cam.zoom + Vector2(pct_zoom, pct_zoom))
		var move_vec = (Vector2(mouse_pos.x, cam.position.y) - cam.position) * pct_zoom
		target_cam_pos = cam.position - move_vec
	if Input.is_action_just_pressed("ui_cancel"):
		# get rid of current thing
		# actually just put it back at the bottom?
		if not selected_building == null:
			remove_child(selected_building)
#			dock.add_specific_building(selected_building)
			dock.visualize_last_removed()
			selected_building = null
	if Input.is_action_just_pressed("ui_right_click"):
		drag_origin = mouse_pos
	if Input.is_action_pressed("ui_right_click"):
		# drag cam
		var pos = mouse_pos - drag_origin
		var drag_speed = 1
		var move = Vector2(pos.x * drag_speed, 0)
		target_cam_pos = cam.position - move
	update_cam()

func select_building(inst):
	if selected_building != null:
		remove_child(selected_building)
#		dock.add_specific_building(selected_building)
		dock.visualize_last_removed()
		selected_building = null
	selected_building = inst
	add_child(inst)
