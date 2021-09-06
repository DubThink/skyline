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
var total_scan_count
func _ready():
	rid = RuntimeImportData.new()
#	var bbd = BuildingBakedDefinition.new()
#	print(bbd)
#	rid.add_building_definition(bbd)
#	save_out()
	data_instance = data_source.instance()
	add_child(data_instance)
	print("STARTING BAKE")
	get_node("status").set_text("Baking...")
	total_scan_count = data_instance.get_child_count()
	

func save_out():
	ResourceSaver.save("res://rid1.res",rid,ResourceSaver.FLAG_CHANGE_PATH+ResourceSaver.FLAG_COMPRESS)
	#rid.take_over_path(rid.resource_path)
	
	var bw = BuildingBakedDefinition.new()
	bw.building_name = "bake3"
	ResourceSaver.save("res://testbw.tres",bw,ResourceSaver.FLAG_CHANGE_PATH)


var bake_target_idx=-1
var scanned_count=0
func get_next_bake_target():
	var child_count = data_instance.get_child_count()
	bake_target_idx+=1
	scanned_count+=1
	if bake_target_idx<=child_count:
		bake_target = data_instance.get_child(bake_target_idx)
		#print("checking ", bake_target)
	
	while not bake_target is BuildingDefinition or bake_target.no_export:
		bake_target_idx+=1
		scanned_count+=1		
		if bake_target_idx<=child_count:
			bake_target = data_instance.get_child(bake_target_idx)
			#print("checking ", bake_target)		
		else:
			break
	
	if bake_target_idx > child_count:
		bake_target = null

var scale_factor
func setup_building_bake(target: BuildingDefinition):
	assert(target)
	print("Setting up bake for ",target,' "',target.name,'"')
	var pos = target.get_position()
	var bounds = target.calculate_bounds()
	var c = Vector2(0,bounds.size.y)
	var ms = max(bounds.size.x,bounds.size.y)
	scale_factor = int(max(1,ceil(log(ms)/log(2))-8))
	print("Scale factor ",scale_factor)
	
	target.get_parent().remove_child(target)
	bake_target_idx-=1
	viewport.add_child(target)
	target.visible=true
	
	#print(offset, bounds)
	# todo figure out why we render out of position on some buildings
	# move shape from at origin of render target to the bottom left corner
	var tex_offset = Vector2(0,512)
	# inset to prevent texture bleed bc wrap mode
	#var margin = Vector2(8,-8)
	# should scale around origin of tex
	# goddammit integer division stupid gtfo
	target.set_scale(Vector2(1.0/scale_factor,1.0/scale_factor))
	# tex_offset - n (in diagram)
	target.set_position(tex_offset - (bounds.position + c)/scale_factor)
	#print(bounds.position + c)
	#print("final position for rendering ",target.position)
	# TODO $AWELSH should this also be scaled
	target.bounds.position = pos+bounds.position+c
	#print("bounds val calculated ",target.bounds.position)
	#print("sum ", target.bounds.position+target.position)
	#if target.name == "Delta Tower":
	#	print("DBG")
	#	baking = false

var baked_count = 0

func finish_building_bake(target: BuildingDefinition):
	print("Finishing up bake for ",target)
	var bbd = BuildingBakedDefinition.new(target)
	var vtex = viewport.get_texture()
	var tex=ImageTexture.new()
	# don't have wrapping so that wrapping edge bleed isn't an issue
	tex.create_from_image(vtex.get_data(), ImageTexture.FLAG_FILTER+ImageTexture.FLAG_MIPMAPS)
	get_node("Preview2").set_texture(tex)
	
	bbd.set_tex(tex)
	bbd.image_scale_factor = scale_factor
	rid.add_building_definition(bbd)
	
	baked_count+=1
	get_node("bake_count").set_text("Baked %d"%[baked_count])

	target.visible=false

var baking = true
var fc = 0


func _process(delta):
	if not baking:
		return
	
	print("### FRAME ",fc," ###")
	fc +=1
	# TODO $AWELSH ditch this
	if fc%2==1:
		return
	if bake_target:
		finish_building_bake(bake_target)
	get_next_bake_target()
	if bake_target:
		setup_building_bake(bake_target)
	else:
		finish_bake()
	get_node("child_count").set_text("Scanned %d/%d"%[scanned_count,total_scan_count])
	

func finish_bake():
	print("Running validation...")
	for bbd in rid.building_definitions:
		assert(bbd)
		assert(bbd is BuildingBakedDefinition)
		bbd.validate()
	print("Saving out...")		
	get_node("status").set_text("Saving...")	
	save_out()		
	print("FINISHED BAKE")
	get_node("status").set_text("Done!")	
	baking = false
