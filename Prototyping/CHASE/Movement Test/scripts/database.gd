extends Node
#THIS IS A SINGLTON AND WILL DEFAULT IN ANY RUNNING SCENE IT DOES NOT NEED TO BE ADDED TO THE SCENE TREE

@export_category("Player Data")
@export var player_data_path = "res://Prototyping/CHASE/Movement Test/Data/Player_Data.json"
var player_dict

func _ready():
	player_dict = _JSON_to_dictionary(player_data_path)
	
func _give_data(give, to : String):
	var target = FileAccess.get_file_as_string(to)

func _remove_data(remove, from : String):
	var target = FileAccess.get_file_as_string(from)

func _JSON_to_dictionary(data_path:String): #returns true if JSON contains key
	var file = FileAccess.get_file_as_string(data_path)
	var dict = JSON.parse_string(file)
	return dict
