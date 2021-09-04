extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var last_viewport_rect;
var sky_viewport;

export var buildingMaterial: ShaderMaterial;

var buildingShader = preload("res://arttest/building_shader.gdshader")
var skyEastMat: ShaderMaterial = preload("res://arttest/sky.material")
var skyWestMat: ShaderMaterial = preload("res://arttest/sky_west.tres")

var world_time: float;

export var SECONDS_PER_DAY=30.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	last_viewport_rect = get_viewport_rect()
	for child in get_children():
		if child is Viewport:
			sky_viewport = child
			break
	assert(sky_viewport)
	
	print(buildingMaterial)
	
	for child in get_parent().get_children():
		print(child)
		if child is BuildingDefinition:
			child.initialize(buildingMaterial)

func notify_resized(new_size: Rect2):
	last_viewport_rect = new_size
	print("Resizing viewport to size ", new_size.size)
	sky_viewport.set_size(new_size.size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var viewport_rect = get_viewport_rect();
	if(!last_viewport_rect.is_equal_approx(viewport_rect)):
		notify_resized(viewport_rect)
	world_time+=delta/SECONDS_PER_DAY
	skyEastMat.set_shader_param("FIXED_TIME_OF_DAY",world_time)
	skyWestMat.set_shader_param("FIXED_TIME_OF_DAY",world_time)



	
