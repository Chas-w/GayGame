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
var can_exit : bool
var trigger_exit : bool #so interactions can't interrupt while exiting an interaction
var follow_up_position


func _ready():
	for game_obj in get_tree().get_nodes_in_group("Database"): #assign database
		database = game_obj
	main_dictionary = database._JSON_to_dictionary(interaction_file_path)
	_setup()

func _process(delta):
	if (trigger_exit && can_exit):
		_exit_interaction()
		can_exit = false

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

func _enter_interaction(): #set up interaction for player
	if (!trigger_exit):
		database._display_ui(database.dialogue_ui)
		database.interaction_name_label.text = ID # assign name to UI
		#check player dictionary -> dialogue manager for all stored conversations, if this conversation ID matches any of those
		#continue the conversation from the cooresponding stored status
		#else, start conversation fresh and add this to the player's list of conversations
		follow_up_position = -1
		database.player_dict.Dialogue_Manager.Current_Conversation_ID = ID
		entered = true
		_progress_interaction()

func _exit_interaction(): #reset everything
	database.player_dict.Stored_Conversations[ID] = player_interaction_status # I think this is adding this value to the dictionary
	database._hide_ui(database.exit_interaction_button)
	database._hide_ui(database.dialogue_ui)
	database._clear_interaction_text()
	entered = false
	progress_info = false
	trigger_exit = false
	print(player_interaction_status)
	pass

func _progress_interaction():
	if (!trigger_exit): #as long as the player isn't in the middle of exiting
		#if default
		progress_info = true #progress the information forward
		if (follow_up_position < _setup().Dialogue.Default.Follow_Up.size() -1 && progress_info): #if we haven't reached the end of the dialogue array
			follow_up_position += 1 #increase the position in the array
			database.player_dict.Dialogue_Manager.Current_Conversation_Status = _setup().Dialogue.Default.Follow_Up[follow_up_position] #current status updated to match current dialogue
			player_interaction_status = database.player_dict.Dialogue_Manager.Current_Conversation_Status #stored within this script 
			progress_info = false #exit loop
			print(player_interaction_status)
		elif(follow_up_position >= _setup().Dialogue.Default.Follow_Up.size() -1 && progress_info): #if larger than array
			database._display_ui(database.exit_interaction_button) #show the option to exit
			can_exit = true #dialogue exitable
			if (_setup().Dialogue.Default.Loop): #if set to loop
				follow_up_position = _setup().Dialogue.Default.Loop_From #update the position in the array to the loop start
				database.player_dict.Dialogue_Manager.Current_Conversation_Status = _setup().Dialogue.Default.Follow_Up[follow_up_position] #current status updated
				player_interaction_status = database.player_dict.Dialogue_Manager.Current_Conversation_Status #stored on this script
				progress_info = false #exit loop
				print(_setup().Dialogue.Default.Follow_Up[follow_up_position])
			#_exit_interaction()
		database.dialogue_label.text = player_interaction_status #update label text
