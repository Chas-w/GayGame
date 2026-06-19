extends Node3D

@export_category("Game States")
enum Game_State{Setup, Exit, Opponent, Strategy, Throw}
@export var game_state : Game_State = Game_State.Setup

@export var head_scroll : VScrollBar
@export var teeth_scroll : HScrollBar
var UI
var pumpit_button : Button
@export var lungs : MeshInstance3D
@export var head : Skeleton3D
var blendshape : float
@export var head_rot : Quaternion
@export var top_teeth : Sprite2D
@export var bottom_teeth : Sprite2D

func _ready(): 
	for game_obj in get_tree().get_nodes_in_group("UI"): #assign database
		UI = game_obj
	pumpit_button = UI.get_child(5)
	blendshape = lungs.get_blend_shape_value(0)
func _process(delta):
	#lungs pump
	if(pumpit_button.button_pressed):
		blendshape += 1 * delta
		lungs.set_blend_shape_value(0,blendshape)
	#head rotation
	head_rot.x = head_scroll.value
	head.set_bone_pose_rotation(head.find_bone("Neck"),head_rot)
	#teeth rotation
	top_teeth.position.x = teeth_scroll.value
	bottom_teeth.position.x = 1600 - teeth_scroll.value
