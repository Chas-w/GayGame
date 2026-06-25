extends Node3D

@export_category("Attributes")
@export var base_impulse : float
@export var max_moves : int

@export_category("References")
@export var pool_canvas : Control
@export var cue_ball : RigidBody3D

#State Machine
enum STATE {Aim, Shoot, Wait}
var current_state : STATE = STATE.Aim

var shoot_ball : bool
var moves_left : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moves_left = max_moves


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		pool_canvas.update_start_point()
	if Input.is_action_pressed("click"):
		pool_canvas.update_end_point()
	if Input.is_action_just_released("click") and moves_left > 0:
		moves_left = moves_left - 1
		var aim_direction = Vector3(pool_canvas.get_aim_vector().x, 0, pool_canvas.get_aim_vector().y)
		var aim_distance = pool_canvas.get_aim_distance()
		print(aim_distance)
		print(aim_distance * base_impulse * aim_direction)
		cue_ball.apply_impulse(aim_distance * base_impulse * aim_direction)
		pool_canvas.update_move_display(moves_left)
		pool_canvas.release_line()
