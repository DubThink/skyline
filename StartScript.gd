extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var audio = get_parent().get_node("BackgroundMusic")
onready var title = get_parent().get_node("GuiLayer/TitleText")
onready var skyrm = get_parent().get_node("SkyRenderManager")
onready var uidock = get_parent().get_node("GuiLayer/MenuDock")
onready var uilabels = get_parent().get_node("GuiLayer/MenuDock/CanvasLayer/LabelPanel")
onready var status = get_parent().get_node("DemandManager/CanvasLayer/Panel")

export (bool) var dev_mode
var cache_spd
# Called when the node enters the scene tree for the first time.
func _ready():
	if dev_mode:
		audio.play()
		state = 99
		title.visible = false
	else:
		skyrm.do_daynight_cycle=false
		cache_spd = skyrm.SECONDS_PER_DAY
		# we need shit faster to start up nicely
		skyrm.SECONDS_PER_DAY = 30
		title.modulate = Color(1,1,1,0)
		uidock.modulate = Color(1,1,1,0)
		uilabels.modulate = Color(1,1,1,0)
		status.modulate = Color(1,1,1,0)
		

var elapsed_time=0
var state = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	if state == 0:
		# initial fade in
		var p = pow(elapsed_time/5.0,2.2)
		get_node("CanvasModulate").color = Color(p,p,p,1)
		if elapsed_time>5.0:
#			print("going to state 1")
			state = 1
			get_node("CanvasModulate").color = Color(1,1,1,1)
			title.modulate = Color(1,1,1,p)
	elif state == 1:
		audio.play()
		skyrm.do_daynight_cycle=true
		elapsed_time = 0
#		print("going to state 2")
		state = 2
	elif state == 2:
		if elapsed_time > 15:
			title.visible=false
			skyrm.SECONDS_PER_DAY = cache_spd
		if elapsed_time > 11:
			var ttime = elapsed_time - 11
			# fade dock in
			var p = pow(ttime/5,2.2)
			uidock.modulate = Color(1,1,1,p)
			uilabels.modulate = Color(1,1,1,p)
			status.modulate = Color(1,1,1,p)
			if elapsed_time > 16:
				uidock.modulate = Color(1,1,1,1)
				uilabels.modulate = Color(1,1,1,1)
				status.modulate = Color(1,1,1,1)
#				print("going to state 3")
				state = 3
				elapsed_time = 0
	pass
