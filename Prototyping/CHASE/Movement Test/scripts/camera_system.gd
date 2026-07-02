extends Node3D
@export var pool_cam : PhantomCamera3D
@export var opponent_cam : PhantomCamera3D
@export var enter_scene_cam : PhantomCamera3D
@export var enter_animator : AnimationPlayer
var animation_buffer = 1.5
var trigger_game : bool 
func _ready():
	_enter_game()

func _enter_game():
	enter_scene_cam.priority = 10
	opponent_cam.priority = 0
	pool_cam.priority = 0
	enter_animator.play("Enter Temp")

func _opponent_view(): 
		enter_scene_cam.priority = 0
		pool_cam.priority = 0
		opponent_cam.priority = 10
		
func _pool_view():
	enter_scene_cam.priority = 0
	opponent_cam.priority = 0
	pool_cam.priority = 10	

func _process(delta):
	if (animation_buffer >= 0):
		animation_buffer -= delta
	else:
		if(!trigger_game):
			_opponent_view()
		else:
			_pool_view()
	if(Input.is_action_just_pressed("ui_accept")):
		trigger_game = true
	pass
