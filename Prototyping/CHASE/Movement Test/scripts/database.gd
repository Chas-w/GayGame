extends Node
#THIS IS A SINGLTON AND WILL DEFAULT IN ANY RUNNING SCENE IT DOES NOT NEED TO BE ADDED TO THE SCENE TREE

@export_category("Player Data")
@export var player_data_path = "res://Prototyping/CHASE/Movement Test/Data/Player_Data.json"

@export_category("Dialogues")
@export var dialogue_template_path = "res://Prototyping/CHASE/Movement Test/Data/Dialogue_Template.json"
#@export var demo_bartender_dialogue_json : JSON

#@export_category("Display Information")
#@export var text_display_title : Label
#@export var text_display_data : Label
#@export var text_display_control : Control
#
#func _display_dialogue(file : String):
	#text_display_control.visible = true
	#var current_dialogue: Dictionary = {}
	#current_dialogue  = JSON.parse_string(file)
	#text_display_title.text = current_dialogue["NAME"]
	#text_display_data.text = current_dialogue["DIALOGUE"]
func _ready():
	print(_parse_dictionary(JSON_to_dictionary(dialogue_template_path), "NPC_Dialogue"))
	pass

func _give_data(give : String, to : String):

	pass

func _remove_data(remove: String, from : String):
	pass

func JSON_to_dictionary(data_path:String): #returns true if JSON contains key
	var file = FileAccess.get_file_as_string(data_path)
	var dict = JSON.parse_string(file)
	return dict

func _parse_dictionary(dict, key : String): 
	return(dict[key])

func _queue_value(): #executes the JSON value based on key
	pass
