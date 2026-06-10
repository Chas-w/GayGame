extends Node3D
@export_category("Setup")
@export var hover_label : Label3D
@export var JSON_file_path : String
@export var progression_icon : Sprite2D
@export_range (0,1.5,.01) var display_buffer #amount of time inbetween each word
var database
var buffer : float = 0
var JSON_dict : Dictionary
var dialogue_dict : Dictionary
var NPC_name : String
var place_in_dialogue : String
var dialogue_array 
var option_container : VBoxContainer
var response_button_path = preload("res://Prototyping/CHASE/Movement Test/scenes/response_button.tscn")
var skip : bool

@export_category("Dialogue_Status")
var entered : bool
var can_exit : bool 
var can_move_scene : bool
var display_line : bool 
var setup_display : bool
var current_dialogue : Dictionary
var current_sentence : String
var split_sentence #an array that stores all the words in a sentence
var word_in_sentence : int #used to track where we are in displaying the sentence
var current_status : String
var player_status : String 
var player_choice : Button
var waiting_for_progression : bool #used if there's not choice just waiting for the player to press interact


func _ready():
	for game_obj in get_tree().get_nodes_in_group("Database"): #assign database
		database = game_obj
	JSON_dict = database._JSON_to_dictionary(JSON_file_path)
	dialogue_dict = JSON_dict.NPC
	NPC_name = dialogue_dict.Name
	dialogue_array = dialogue_dict.Dialogue
	option_container = database.dialogue_ui.get_child(2)
	
func _process(delta):
	if (waiting_for_progression):
#		progression_icon.visible = true
		if (Input.is_action_just_pressed("interact")):
			_progress_dialogue(current_dialogue.Next_Status)
			waiting_for_progression = false
#			progression_icon.visible = false
	if (display_line):
		_display_dialogue(current_dialogue.Line, delta)

func _display_dialogue(disp : String, delta):
	if (!setup_display):
		print("[" + NPC_name + " Current Sentence]: " + disp)
		buffer = randf_range(.01,display_buffer)
		split_sentence = disp.split(" ") 
		word_in_sentence = -1
		current_sentence = " "
		database.dialogue_label.text = " "
		setup_display = true
	else:
		if (Input.is_action_just_pressed("interact")):
			skip = true
		if(buffer >= 0):
			buffer -= delta
		else: 
			if (word_in_sentence < split_sentence.size()-1 && !skip):
				if (!skip):
					word_in_sentence += 1
					current_sentence += split_sentence[word_in_sentence] + " "
					database.dialogue_label.text = current_sentence #update label text
					#play audio
					buffer = randf_range(.01,display_buffer)
			else:
				if (skip):
					current_sentence = " " + disp
					database.dialogue_label.text = current_sentence #update label text
					print("[SKIP '"+disp+"' WRITTEN OUT]")
				if (current_dialogue.Player_Response):
					_display_options()
				else:
					waiting_for_progression = true
				if (current_dialogue.End_Conversation):
					can_exit = true
					database.exit_interaction_button.visible = true
				display_line = false
				setup_display = false
				skip = false


func _progress_dialogue(status : String): #used to call and display next dialogue option
	hover_label.visible = false
	database._display_ui(database.dialogue_ui)
	database.speaker_name_label.text = NPC_name
	if (!display_line):
		for i in dialogue_array.size():
			if (dialogue_array[i].Status_is_Array):
				for s in dialogue_array[i].Status.size():
					if (dialogue_array[i].Status[s] == status):
						current_dialogue = dialogue_array[i]
						display_line = true
			else:
				if (dialogue_array[i].Status == status):
					current_dialogue = dialogue_array[i]
					display_line = true
	else:
		return

func _display_options():
	print("[Player Current Options]: ")
	var options = current_dialogue.Response_Options
	print(options)
	for o in options.size(): #this response
		var button_instance = response_button_path.instantiate()
		option_container.add_child(button_instance)
		button_instance.dialogue_manager = self
		button_instance.text = options[o]
		for i in options.size(): #connected responses
			if (button_instance.text != options[i]):
				button_instance.connected_responses.append(options[i])

func _player_response(response_choice : Button):
	for game_obj in get_tree().get_nodes_in_group("Response"): #assign database
		for i in response_choice.connected_responses.size():
			if(game_obj.text == response_choice.connected_responses[i]):
				print("[Removing: '" + response_choice.connected_responses[i] + "' Option]")
				game_obj.queue_free()
	print("[Executing: '" + response_choice.text + "' Option]")
	_progress_player_response(response_choice.text)
	response_choice.queue_free()

func _progress_player_response(status : String):
	player_status = status
	#update JSON
	_progress_dialogue(status)


func _enter_dialogue():
	_progress_dialogue("Opener")
	entered = true
	pass

func _exit_dialogue():
	hover_label.visible = true
	database.exit_interaction_button.visible = false
	can_exit = false
	database._clear_dialogue_text()
	database._hide_ui(database.dialogue_ui)
	hover_label.text = current_dialogue.Exit_Line
	print("[EXITING CONVERSATION WITH '"+NPC_name+"']")
