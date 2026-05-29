extends Node3D

@export_category("Setup")
@export var is_dialogue : bool
var player_banter : bool
var dialogue = {}

@export var interaction_file_path : String
@export var ID : String
@export var target_name : String
@export var scene_group : String

var database : Node
var main_dictionary #overarching folder that contains all the data within this JSON file
var player #for temp use... will usually be NULL

func _ready():
	for game_obj in get_tree().get_nodes_in_group("Database"): #assign database
		database = game_obj
	main_dictionary = database._JSON_to_dictionary(interaction_file_path)

func _process(delta):
	pass

func _enter_interaction():
	var current_dictionary = " "
	if (is_dialogue):
		current_dictionary = database._parse_dictionary(main_dictionary,"NPC_Dialogue")
		ID = database._parse_dictionary(current_dictionary,"ID")
		scene_group = database._parse_dictionary(current_dictionary,"Scene_Group")
		target_name = database._parse_dictionary(current_dictionary, "Target_Name")
		player_banter = database._parse_dictionary(current_dictionary,"Player_Banter")
		dialogue = database._parse_dictionary(current_dictionary,"Dialogue")
		
	#else: parse as though inspectable object
	return current_dictionary

func _exit_interaction(): 
	pass

func _process_interaction():
	pass
