extends Node

@export_category("Player Data")
@export var player_data : JSON

@export_category("Dialogues")
@export var dialogue_template : JSON
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
