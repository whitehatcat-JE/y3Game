extends Node

signal event(identifier:String, value)

signal triggerDialogue(identifier)

signal eventFinished

var entranceName:String = ""

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	RenderingServer.set_default_clear_color(Color.BLACK)

func _input(event):
	if Input.is_action_just_pressed("quit"): get_tree().quit();
