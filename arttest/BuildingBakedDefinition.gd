extends Resource

class_name BuildingBakedDefinition

# from def
export (String) var building_name = null
export (BUILDING.TYPE, FLAGS ) var building_type
export (BUILDING.LAYER) var layer
export (int, 0, 50) var person_capacity
# calculated
export (Rect2) var bounds
# tex
export (ImageTexture) var src_tex
# ??
export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(var def:BuildingDefinition=null):
	if def:
		print(def)
		print(def.name)
		building_name = def.name
		building_type = def.building_type
		layer = def.layer
		person_capacity = def.person_capacity
		bounds = def.bounds
	
func set_tex(var tex: ImageTexture):
	assert(tex)
	src_tex = tex

func validate():
	assert(building_name)
	assert(src_tex)

func get_residentialness():
	print(building_name)
	print(building_type)
	print(1<<BUILDING.TYPE.HOUSE & building_type)
	print(1<<BUILDING.TYPE.FOOD & building_type)
	
