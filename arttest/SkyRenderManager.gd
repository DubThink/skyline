extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name SkyRenderManager

var last_viewport_rect;
var sky_viewport;

export var buildingMaterial: ShaderMaterial;



var buildingShader = preload("res://arttest/building_shader.gdshader")
var skyEastMat: ShaderMaterial = preload("res://arttest/sky.material")
var skyWestMat: ShaderMaterial = preload("res://arttest/sky_west.tres")

var world_time: float;
var do_daynight_cycle=true


var building_shaders_to_update: Array;

export var SECONDS_PER_DAY=30.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	last_viewport_rect = get_viewport_rect()
	for child in get_children():
		if child is Viewport:
			sky_viewport = child
			break
	assert(sky_viewport)
	print("Setting up building material...")
	buildingMaterial.set_shader_param("sky_target", get_node("Viewport").get_texture())
#	for child in get_parent().get_children():
#		print(child)
#		if child is BuildingDefinition:
#			child.initialize(buildingMaterial)

func notify_resized(new_size: Rect2):
	last_viewport_rect = new_size
	print("Resizing viewport to size ", new_size.size)
	sky_viewport.set_size(new_size.size)

func instance_and_track_building_shader():
	var mat = buildingMaterial.duplicate()
	building_shaders_to_update.append(mat)
	return mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var viewport_rect = get_viewport_rect();
	if(!last_viewport_rect.is_equal_approx(viewport_rect)):
		notify_resized(viewport_rect)
	if do_daynight_cycle:
		world_time+=delta/SECONDS_PER_DAY
		skyEastMat.set_shader_param("FIXED_TIME_OF_DAY",world_time)
		skyWestMat.set_shader_param("FIXED_TIME_OF_DAY",world_time)
		for building_shader in building_shaders_to_update:
			assert(building_shader is ShaderMaterial)
			building_shader.set_shader_param("FIXED_TIME_OF_DAY",world_time)
		
		

