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
var player_interaction_status : String #where the player is at in the conversation/interaction/quest
var progress_info : bool
var entered : bool 
var follow_up_position

func _ready():
	for game_obj in get_tree().get_nodes_in_group("Database"): #assign database
		database = game_obj
	main_dictionary = database._JSON_to_dictionary(interaction_file_path)
	_setup()


func _setup(): #sets up all the interaction variables and stores the dictionary that will be referenced
	var current_dictionary = " "
	if (is_dialogue):
		current_dictionary = main_dictionary.NPC_Dialogue
		ID = current_dictionary.ID
		scene_group = current_dictionary.Scene_Group
		target_name = current_dictionary.Target_Name
		player_banter = current_dictionary.Player_Banter
		dialogue = current_dictionary.Dialogue
	#else: parse as though inspectable object
	return current_dictionary

func _enter_interaction():
	#check player dictionary -> dialogue manager for all stored conversations, if this conversation ID matches any of those
	#continue the conversation from the cooresponding stored status
	#else, start conversation fresh and add this to the player's list of conversations
	follow_up_position = -1
	database.player_dict.Dialogue_Manager.Current_Conversation_ID = ID
	entered = true
	_progress_interaction()
	pass

func _exit_interaction(): 
	database.player_dict.Stored_Conversations[ID] = player_interaction_status # I think this is adding this value to the dictionary
	pass

func _progress_interaction():
	#if default
	progress_info = true
	if (follow_up_position < _setup().Dialogue.Default.Follow_Up.size() -1 && progress_info):
		follow_up_position += 1
		database.player_dict.Dialogue_Manager.Current_Conversation_Status = _setup().Dialogue.Default.Follow_Up[follow_up_position]
		progress_info = false
		print(database.player_dict.Dialogue_Manager.Current_Conversation_Status)
		return
	elif(follow_up_position >= _setup().Dialogue.Default.Follow_Up.size() -1 && progress_info):
		if (_setup().Dialogue.Default.Loop):
			follow_up_position = _setup().Dialogue.Default.Loop_From
			database.player_dict.Dialogue_Manager.Current_Conversation_Status = _setup().Dialogue.Default.Follow_Up[follow_up_position]
			return
		_exit_interaction()
