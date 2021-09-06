extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var exit_btn = get_node("ExitButton")
onready var cancel_btn = get_node("CancelButton")

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_btn.connect("pressed", self, "on_click_exit")
	cancel_btn.connect("pressed", self, "on_click_cancel")

func on_click_exit():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	
func on_click_cancel():
	#TODO $AWELSH unpause day/night cycle
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
