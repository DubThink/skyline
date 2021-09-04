extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var conductivity = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func evolve_happiness(h, dt):
	var o = []
	for i in h:
		o.append(0)
	for i in range(len(h)):
		if i == 0:
			o[i] = conductivity * (h[1] - h[0] ) * dt + h[0]
		elif i == len(h)-1:
			o[i] = conductivity * (h[i - 1] - h[i]) * dt + h[i]
		else:
			o[i] = h[i] + conductivity * dt * ((h[i+1] - h[i]) - (h[i] - h[i-1]))
	return o

func happiness_sum(h, base_happiness):
	var o = 0
	for i in h:
		o += (i - base_happiness)
	return o



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
