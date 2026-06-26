extends Node3D

@export_category("Attributes")
@export var base_impulse : float
@export var max_moves : int

@export_category("References")
@export var pool_canvas : Control
@export var cue_ball : RigidBody3D
@export var camera : Camera3D

#State Machine
enum STATE {Aim, Shoot, Wait, Ready}
var current_state : STATE = STATE.Ready

var moves_left : int

#Ball Hit
var aim_direction
var aim_distance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moves_left = max_moves
	pool_canvas.pool_manager = self
	pool_canvas.update_move_display(moves_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match(current_state):
		STATE.Ready:
			var ball_is_ready = camera.is_over_ball and cue_ball.get_velocity() == 0
			if Input.is_action_just_pressed("click") and ball_is_ready:
				pool_canvas.update_start_point()
				setup_state(STATE.Aim)
		STATE.Aim:
			pool_canvas.update_end_point()

func _physics_process(delta: float) -> void:
	match(current_state):
		STATE.Ready:
			pass
		STATE.Aim:
			if Input.is_action_just_released("click") and moves_left > 0 :
				moves_left = moves_left - 1
				pool_canvas.update_move_display(moves_left)
				pool_canvas.release_line()
				aim_direction = Vector3(pool_canvas.get_aim_vector().x, 0, pool_canvas.get_aim_vector().y)
				aim_distance = pool_canvas.get_aim_distance()
				setup_state(STATE.Wait)
		STATE.Shoot:
			#var aim_direction = Vector3(pool_canvas.get_aim_vector().x, 0, pool_canvas.get_aim_vector().y)
			#var aim_distance = pool_canvas.get_aim_distance()
			cue_ball.apply_impulse(aim_distance * base_impulse * aim_direction)
			setup_state(STATE.Ready)


func setup_state(next_state:STATE) -> void:
	match(current_state):
		STATE.Ready:
			pass
		STATE.Aim:
			pass
		STATE.Shoot:
			pass
		STATE.Wait:
			pass
	current_state = next_state

func hit_ball() -> void:
	setup_state(STATE.Shoot)
