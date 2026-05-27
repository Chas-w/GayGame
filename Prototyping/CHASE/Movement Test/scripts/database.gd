extends Node

@export var text_display_title : Label
@export var text_display_data : Label
@export var text_display_control : Control




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _display_dialogue(file : String):
	text_display_control.visible = true
	var current_dialogue: Dictionary = {}
	current_dialogue  = JSON.parse_string(file)
	text_display_title.text = current_dialogue["NAME"]
	text_display_data.text = current_dialogue["DIALOGUE"]
