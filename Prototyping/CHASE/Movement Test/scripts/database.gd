extends Node
#THIS IS A SINGLTON AND WILL DEFAULT IN ANY RUNNING SCENE IT DOES NOT NEED TO BE ADDED TO THE SCENE TREE

@export_category("Player Data")
@export var player_data_path = "res://Prototyping/CHASE/Movement Test/Data/Player_Data.json"

func _give_data(give : String, to : String):

	pass

func _remove_data(remove: String, from : String):
	pass

func _JSON_to_dictionary(data_path:String): #returns true if JSON contains key
	var file = FileAccess.get_file_as_string(data_path)
	var dict = JSON.parse_string(file)
	return dict

func _parse_dictionary(dict, key : String): 
	return(dict[key])

func _queue_value(): #executes the JSON value based on key
	pass
