extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var conductivity = 2
onready var skyline = get_tree().find_node("SkylineLayer")
var quantization_interval = 1000
var quantization_rate = 1.0 / quantization_interval

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func evolve_happiness(h, dt):
	var o = []
	for i in h:
		o.append(0)
	if len(h) < 3:
		return h
	for i in range(len(h)):
		if i == 0:
			o[i] = conductivity * (h[1] - h[0]) * dt + h[0]
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

# quantizes the happiness for locations to allow for discrete evolution
func happiness_heat_helper(building_list):
	var adjusted = []
	var farthest_building = 1.0 / building_list[len(building_list)][1]
	for i in range(quantization_interval):
		adjusted.append(0)
	for i in building_list:
		var adjusted_position = i[1] * quantization_rate * farthest_building
		var base_position = floor(adjusted_position)
		var building_happiness = i[0].average_happiness
		var distance_vars = [1.0/pow(adjusted_position - base_position - 1, 2), 
							 1.0/pow(adjusted_position - base_position, 2),
							 1.0/pow(adjusted_position - base_position + 1, 2),
							 1.0/pow(adjusted_position - base_position + 2, 2)]
		if !(adjusted_position < 1 or adjusted_position > quantization_interval - 1):
			adjusted[base_position - 1] += distance_vars[0] * building_happiness / 6
			adjusted[base_position]     += distance_vars[1] * building_happiness / 3
			adjusted[base_position + 1] += distance_vars[2] * building_happiness / 3
			adjusted[base_position + 2] += distance_vars[3] * building_happiness / 6
		elif !(adjusted_position < 1):
			adjusted[base_position]     += distance_vars[1] * building_happiness / 2
			adjusted[base_position + 1] += distance_vars[2] * building_happiness / 2
		else:
			adjusted[base_position - 1] += distance_vars[0] * building_happiness / 2
			adjusted[base_position]     += distance_vars[1] * building_happiness / 2
	return adjusted

func recover_happiness_radiation(house, building_list, adjusted):
	var average_happiness = 0
	var farthest_building = 1.0 / building_list[len(building_list)][1]
	var adj_pos = house[1] * quantization_rate * farthest_building
	for i in range(len(adjusted)):
		average_happiness += adjusted[i] * pow(adj_pos - i, -2)
	house.average_happiness = average_happiness
	return

func daily_happiness(building_list):
	var all_people = get_tree().get_nodes_in_group("people")
	for i in all_people:
		i.home.average_happiness += i.current_happiness
		i.home.n_residents += 1
	for i in building_list:
		i[0].average_happiness /= i[0].n_residents
	var spread = evolve_happiness(happiness_heat_helper(building_list), 1)
	for i in building_list:
		recover_happiness_radiation(i, building_list, spread)
	for i in all_people:
		i.current_happiness = i.home.average_happiness
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
