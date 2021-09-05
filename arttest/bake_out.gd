extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rid: RuntimeImportData
const data_source = preload("res://arttest/art_lib.tscn")
var data_instance
onready var viewport: Viewport = get_node("Viewport")
# Called when the node enters the scene tree for the first time.
var bake_target
func _ready():
	rid = RuntimeImportData.new()
#	var bbd = BuildingBakedDefinition.new()
#	print(bbd)
#	rid.add_building_definition(bbd)
#	save_out()
	data_instance = data_source.instance()
	add_child(data_instance)
	print("STARTING BAKE")
	

func save_out():
	ResourceSaver.save("res://rid1.tres",rid,ResourceSaver.FLAG_CHANGE_PATH)
	#rid.take_over_path(rid.resource_path)
	
	var bw = BuildingBakedDefinition.new()
	bw.building_name = "bake3"
	ResourceSaver.save("res://testbw.tres",bw,ResourceSaver.FLAG_CHANGE_PATH)


var bake_target_idx=-1
func get_next_bake_target():
	var child_count = data_instance.get_child_count()
	print("ct",child_count)
	bake_target_idx+=1
	
	if bake_target_idx<=child_count:
		bake_target = data_instance.get_child(bake_target_idx)
		print("checking ", bake_target)
	
	while not bake_target is BuildingDefinition or bake_target.no_export:
		bake_target_idx+=1
		if bake_target_idx<=child_count:
			bake_target = data_instance.get_child(bake_target_idx)
			print("checking ", bake_target)		
		else:
			break
	
	if bake_target_idx > child_count:
		bake_target = null


func setup_building_bake(target: BuildingDefinition):
	assert(target)
	print("Setting up bake for ",target)
	var offset = target.get_position()
	offset.y*=-1
	target.get_parent().remove_child(target)
	bake_target_idx-=1
	viewport.add_child(target)
	target.visible=true
	var bounds = target.calculate_bounds(offset)
	print(offset, bounds)
	# todo figure out why we render out of position on some buildings
	target.set_position(Vector2(8,504)+(bounds.position-offset)*Vector2(-1,1))


func finish_building_bake(target: BuildingDefinition):
	print("Finishing up bake for ",target)
	var bbd = BuildingBakedDefinition.new(target)
	var vtex = viewport.get_texture()
	var tex=ImageTexture.new()
	tex.create_from_image(vtex.get_data())
	get_node("Preview2").set_texture(tex)
	
	bbd.set_tex(tex)
	rid.add_building_definition(bbd)

	target.visible=false

var baking = true
var fc = 0


func _process(delta):
	if not baking:
		return
	
	print("### FRAME ",fc," ###")
	fc +=1
	if fc%2==1:
		return
	if bake_target:
		finish_building_bake(bake_target)
	get_next_bake_target()
	if bake_target:
		setup_building_bake(bake_target)
	else:
		finish_bake()
		

func finish_bake():
	print("Running validation...")
	for bbd in rid.building_definitions:
		assert(bbd)
		assert(bbd is BuildingBakedDefinition)
		bbd.validate()
	print("Saving out...")		
	save_out()		
	print("FINISHED BAKE")
	baking = false
