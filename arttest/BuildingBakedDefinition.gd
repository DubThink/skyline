extends Resource
export(int) var health
export(ImageTexture) var sub_resource
export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_health = 0, p_sub_resource = null, p_strings = []):
	health = p_health
	sub_resource = p_sub_resource
	strings = p_strings

# bot.gd
extends KinematicBody

export(Resource) var stats

func _ready():
	# Uses an implicit, duck-typed interface for any 'health'-compatible resources.
	if stats:
		print(stats.health) # Prints '10'.
