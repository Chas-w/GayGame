extends Node3D

@export_category("Attributes")
@export var base_impulse : float = 0.015
@export var max_impulse : float = 4
@export var max_moves : int = 5

@export_category("Ball References")
@export var cue_ball : RigidBody3D
@export var player_balls : Array[RigidBody3D]
@export var enemy_balls : Array[RigidBody3D]

@export_category("References")
@export var pool_canvas : Control
@export var camera : Camera3D

#State Machine
enum STATE {Aim, Shoot, Wait, Ready, End}
var current_state : STATE = STATE.Ready

#Track progress
var moves_left : int
var player_balls_sunk : int

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
	pool_canvas.update_action_cam(cue_ball)
	match(current_state):
		STATE.Ready:
			#Check if ball is stationary
			var ball_is_stationary = cue_ball.get_velocity() < 0.02
			if ball_is_stationary:
				#Turn off action camera
				#pool_canvas.toggle_action_cam(false)
				#Restart level if no moves left
				if moves_left == 0 and Input.is_action_just_pressed("rightclick"):
					restart_level()
			
			#Get the ball ready to be shot
			var ball_is_ready = camera.is_over_ball and ball_is_stationary and moves_left > 0
			if Input.is_action_just_pressed("click") and ball_is_ready:
				pool_canvas.update_start_point()
				cue_ball.reset_velocity()
				setup_state(STATE.Aim)
		STATE.Aim:
			pool_canvas.update_end_point()
		STATE.Shoot:
			pass

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
			var shoot_power = aim_distance * base_impulse
			if shoot_power > max_impulse:
				shoot_power = max_impulse
			cue_ball.apply_impulse(aim_distance * base_impulse * aim_direction)
			#pool_canvas.toggle_action_cam(true)
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
		STATE.End:
			pool_canvas.update_game_message("GAME OVER")
	current_state = next_state

func hit_ball() -> void:
	setup_state(STATE.Shoot)

func restart_level() -> void:
	get_tree().reload_current_scene()

func _on_floor_trigger_enter(body: Node3D) -> void:
	if body is not RigidBody3D:
		return
	var current_body : RigidBody3D = body
	current_body.freeze = true
	process_ball_sink(body.identity)

func process_ball_sink(identity:int):
	match(identity):
		0: #Cue
			print("Sunk Cue Ball")
			restart_level()
		1: #Player
			print("Sunk Player Ball")
			pool_canvas.update_game_message("SUNK PLAYER BALL")
			player_balls_sunk = player_balls_sunk + 1
			if player_balls_sunk == player_balls.size():
				setup_state(STATE.End)
		2: #Enemy
			print("Sunk Enemy Ball")
			pool_canvas.update_game_message("SUNK ENEMY BALL")
			moves_left = moves_left - 1
			pool_canvas.update_move_display(moves_left)
