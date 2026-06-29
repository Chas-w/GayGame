extends Node3D

@export_category("Attributes")
@export var base_force : float

@export_category("Game States")
enum Game_State{Setup, Exit, Opponent, Strategy, Throw}
@export var game_state : Game_State = Game_State.Setup

@export_category("Ball References")
@export var pong_ball : RigidBody3D
@export var ball_start : Node3D

@export_category("UI References")
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

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("rightclick"):
		print(blendshape)
		var x_ratio = teeth_scroll.value / teeth_scroll.max_value
		print(x_ratio)
		var y_ratio = -head_scroll.value / head_scroll.max_value
		print(y_ratio)
		var z_ratio = 1
		var impulse_direction = Vector3(x_ratio, y_ratio * 2, z_ratio * 1.5)
		throw_ball(blendshape, impulse_direction)

func throw_ball(impulse_multipler : float, impulse_direction : Vector3) -> void:
	pong_ball.freeze = false
	pong_ball.apply_impulse(impulse_direction.normalized() * impulse_multipler * base_force)

func reset_ball() -> void:
	pong_ball.freeze = true
	pong_ball.position = ball_start.position
	pong_ball.rotation = ball_start.rotation
