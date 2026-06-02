extends Node3D

@export_category("Setup")
@export var is_dialogue : bool
var player_banter : bool
var dialogue = {}
@export var next_scene_path : String
@export var interaction_file_path : String
@export var ID : String
@export var target_name : String
@export var scene_group : String

@export_category("Display Settings")
@export_range (0,1.5,.01) var display_buffer #amount of time inbetween each word
var buffer : float = 0
var current_sentence : String
var split_sentence #an array that stores all the words in a sentence
var word_in_sentence : int #used to track where we are in displaying the sentence
var setup_word_display : bool #used to do an initial setup of function variables
var trigger_word_display : bool #used to process displaying sentence

@export_category("process information")
var database : Node
var main_dictionary #overarching folder that contains all the data within this JSON file
var player_interaction_status : String #where the player is at in the conversation/interaction/quest
var progress_info : bool
var entered : bool 
var can_exit : bool
var can_move_scene : bool
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
	if(trigger_word_display):
		_display_sentence(player_interaction_status,delta)

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
	pass

func _next_scene():
	_exit_interaction()
	#save data
	database._go_to_scene(next_scene_path)

func _display_sentence(sentence : String,delta):
	if (!setup_word_display):
		print("[" + ID + " Current Sentence]: " + sentence)
		buffer = randf_range(.01,display_buffer)
		split_sentence = sentence.split(" ") 
		current_sentence = " "
		word_in_sentence = -1
		setup_word_display = true
	else:
		if(buffer >= 0):
			buffer -= delta
		else: 
			if (word_in_sentence < split_sentence.size()-1):
				word_in_sentence += 1
				current_sentence += split_sentence[word_in_sentence] + " "
				database.dialogue_label.text = current_sentence #update label text
				buffer = randf_range(.01,display_buffer)
			else:
				trigger_word_display = false
				setup_word_display = false
		if(Input.is_action_just_pressed("interact")):
			database.dialogue_label.text = " " + sentence
		if(database.dialogue_label.text == " " + sentence):
			trigger_word_display = false
			setup_word_display = false

func _progress_interaction():
	if (trigger_exit): #don't progress while exiting
		return
	if(trigger_word_display):
		return
	var dialogue_data = _setup().Dialogue.Default
	var follow_up = dialogue_data.Follow_Up
	var last_index = follow_up.size() - 1
	
	if (follow_up_position < last_index): #if end of the dialogue array hasn't been reached
		follow_up_position += 1 
		player_interaction_status = follow_up[follow_up_position] #current dialogue stored within this script
		database.player_dict.Dialogue_Manager.Current_Conversation_Status = player_interaction_status #current status updated to match current dialogue
		if (follow_up_position == last_index): #if on last line of dialogue
			if (dialogue_data.Scene_Transition == true):
				can_move_scene = true
				database._display_ui(database.lets_go_button)
			database._display_ui(database.exit_interaction_button) #show the option to exit
			can_exit = true #dialogue exitable
	else: #already on the last line
		if (dialogue_data.Loop): #if set to loop
			follow_up_position = dialogue_data.Loop_From #update the position in the array to the loop start
			player_interaction_status = follow_up[follow_up_position] #current status updated
			database.player_dict.Dialogue_Manager.Current_Conversation_Status = player_interaction_status
	trigger_word_display = true
