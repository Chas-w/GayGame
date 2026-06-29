extends Node

@export var player : Array[Node2D] 
@export var target_text : RichTextLabel
@export var spoken_text : RichTextLabel
@export var their_text : RichTextLabel

var player_1_right_key
var player_1_left_key
var player_1_above_key
var player_1_below_key
var player_1_current_key

var success_response = "Let's take this back to my place"
var fail_response = "eww what?"

func _process(delta):
	_player_1_input()

func _on_player_1_entered(area): #Set player positions
	player_1_right_key = area.get_parent().right_key
	player_1_left_key = area.get_parent().left_key
	player_1_above_key = area.get_parent().above_key
	player_1_below_key = area.get_parent().below_key
	player_1_current_key = area.get_parent()
func _player_1_input():
	if (Input.is_action_just_pressed("enter")):
		if (player_1_current_key.enter):
			if (spoken_text.text == target_text.text):
				their_text.text = success_response
			pass
		elif (player_1_current_key.space):
			spoken_text.text += " "
			pass
		else:
			spoken_text.text += player_1_current_key.text
	
	if (Input.is_action_just_pressed("right")):
		_move_player_1(player_1_right_key)
	if (Input.is_action_just_pressed("left")):
		_move_player_1(player_1_left_key)
	if (Input.is_action_just_pressed("up")):
		_move_player_1(player_1_above_key)
	if (Input.is_action_just_pressed("down")):
		_move_player_1(player_1_below_key)
func _move_player_1(next):
	player[0].position = next.hover_position
	pass
