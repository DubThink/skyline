extends Resource

class_name BuildingBakedDefinition

# from def
export (String) var building_name = null
export (BUILDING.TYPE, FLAGS ) var building_type
export (BUILDING.LAYER) var layer
export (int, 0, 50) var person_capacity

# tex
export (int) var width
export (int) var height
export (ImageTexture) var src_tex
export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(var def:BuildingDefinition=null):
	if def:
		building_name = def.building_name
		building_type = def.building_type
		layer = def.layer
		person_capacity = def.person_capacity
	
func set_tex(var tex: ImageTexture, var p_width: int, var p_height: int):
	assert(tex)
	assert(p_width>0)
	assert(p_height>0)
	src_tex = tex
	width = p_width
	height = p_height

func validate():
	assert(building_name)
	assert(src_tex)
	assert(width>0)
	assert(height>0)
