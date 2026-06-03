extends Node
#THIS IS A SINGLTON AND WILL DEFAULT IN ANY RUNNING SCENE IT DOES NOT NEED TO BE ADDED TO THE SCENE TREE

@export_category("Player Data")
@export var player_data_path = "res://Prototyping/CHASE/Movement Test/Data/Player_Data.json"
var player_dict

@export_category("UI Data")
@export var UI : CanvasLayer
@export var dialogue_ui : Control
@export var dialogue_label : RichTextLabel
@export var interaction_name_label : Label
@export var lets_go_button : Button
@export var exit_interaction_button : Button



func _ready():
	player_dict = _JSON_to_dictionary(player_data_path)
	#region Store UI Data
	for game_obj in get_tree().get_nodes_in_group("UI"): #assign database
		UI = game_obj
	dialogue_ui = UI.dialogue_ui
	dialogue_label = dialogue_ui.get_child(0).get_child(0)
	interaction_name_label = dialogue_ui.get_child(1).get_child(0)
	exit_interaction_button = dialogue_ui.get_child(0).get_child(1)
	lets_go_button = dialogue_ui.get_child(0).get_child(2)
	#endregion
	_hide_ui(dialogue_ui)
	
func _give_data(give, to : String):
	var target = FileAccess.get_file_as_string(to)

func _remove_data(remove, from : String):
	var target = FileAccess.get_file_as_string(from)

func _JSON_to_dictionary(data_path:String): #returns true if JSON contains key
	var file = FileAccess.get_file_as_string(data_path)
	var dict = JSON.parse_string(file)
	return dict

func _display_ui(ui_control : Control):
	ui_control.visible = true

func _hide_ui(ui_control : Control):
	ui_control.visible = false

func _clear_interaction_text():
	dialogue_label.text = " "
	interaction_name_label.text = " "
	pass

func _go_to_scene(target_scene : String):
	get_tree().change_scene_to_file(target_scene)
	pass

func _save_scene_data():
	pass
