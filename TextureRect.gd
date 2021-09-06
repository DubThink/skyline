extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

#	#bw.take_over_path(bw.resource_path)
#	var a = ResourceLoader.load("res://testbw.tres","",false)
#
#
#	var bw2 = BuildingBakedDefinition.new()
#	ResourceSaver.save("res://testbw.tres",bw2,ResourceSaver.FLAG_CHANGE_PATH)
	#bw2.take_over_path(bw2.resource_path)
	
	var a = ResourceLoader.load("res://testbw.tres","",true)
	var b = ResourceLoader.load("res://rid1.res","",true)
	#print(a.building_name)
	print(a.building_name)
	for b2 in b.building_definitions:
		print(b2.building_name)
	#print(a.building_definitions[0].src_tex)
	#set_texture(a.building_definitions[0].src_tex)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
