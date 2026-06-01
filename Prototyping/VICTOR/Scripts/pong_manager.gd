extends Node3D

#Serialize Variables
@export_group("Attributes")
@export var pong_ball : RigidBody3D
@export var default_throw_force : float
@export var default_up_force : float

@export_group("Cup References")
@export var player_cups : Array[MeshInstance3D]
@export var enemy_cups : Array[MeshInstance3D]
@export var enemy_moves : Array[bool]

@export_group("UI References")
@export var canvas : Control
@export var player_move_display : Label
@export var enemy_move_display : Label
@export var state_display : Label
@export var result_display : Label

@export_group("References")
@export var ball_start : Node3D
@export var ball_idle : Node3D
@export var opponent_miss : Node3D
@export var table : Node3D
@export var opponent : Node3D

#State Management
enum STATE {None, Player, Wait, Transition, Enemy, End}
var current_state = STATE.None
var state_before_wait : STATE
var state_after_transition : STATE

#NONE: nothing
#Player: player can throw ball
#Wait: computer waits for player or enemy to throw the ball, waits to see result
#Transition: purely a timer, waits a second before moving to next state
#Enemy takes a turn, defined by bools in enemy moves array

var wait_timer : float
var point_scored : bool

#Tracking Moves
var current_player_move : int = 0
var current_enemy_move : int = 0
var player_balls_left : int = 0

#Local Variables
var ready_to_throw : bool
var start_point : Vector2

#Spare Balls
var spare_prefab = preload("res://Prototyping/VICTOR/Prefabs/spare_ball.tscn")
var spare_balls : Array[MeshInstance3D]

var winner : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set Manager in Player Cups
	for i in range(player_cups.size()):
		player_cups[i].manager = self
	for i in range(enemy_cups.size()):
		enemy_cups[i].manager = self
	
	#Setup display
	result_display.text = ""
	player_balls_left = 2
	canvas.update_ball_display(player_balls_left)
	
	#Setup Game
	setup_state(STATE.Player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#MANAGE STATE FUNCTIONS
	match current_state:
		STATE.None:
			if Input.is_action_just_pressed("enter"):
				setup_state(STATE.Player)
		STATE.Player:
			#Display player balls:
			player_move_display.text = "Balls Remaining: " + str(player_balls_left)
			#Start throwing the ball
			if Input.is_action_pressed("click") and !ready_to_throw:
				ready_to_throw = true
				start_point = canvas.get_global_mouse_position()
				canvas.set_start_point()
			if ready_to_throw:
				canvas.update_end_point()
		STATE.Wait:
			#Display player balls:
			if state_before_wait == STATE.Player:
				player_move_display.text = "Balls Remaining: " + str(player_balls_left)
			#Track wait_time
			wait_timer = wait_timer + delta
			if !point_scored and wait_timer > 5:
				process_wait()
			if point_scored and wait_timer > 2:
				process_wait()
			#Make sure ball is in the right place
			if pong_ball.position.y < -3 or pong_ball.position.y > 3:
				if state_before_wait == STATE.Enemy:
					canvas.display_message("OPPONENT MISS")
				process_wait()
		STATE.Transition:
			wait_timer = wait_timer + delta
			if wait_timer > 2:
				wait_timer = 0
				setup_state(state_after_transition)
		STATE.Enemy:
			wait_timer = wait_timer + delta
			if wait_timer > 2:
				wait_timer = 0
				opponent.switch_to_throw()
				if current_enemy_move < enemy_moves.size() - 1:
					if enemy_moves[current_enemy_move] and !enemy_cups.is_empty():
						spawn_random_opponent_throw()
					else:
						spawn_opponent_miss()
					setup_state(STATE.Wait)
				else:
					print("invalid enemy move")
		STATE.End:
			wait_timer = wait_timer + delta
			if wait_timer > 10:
				wait_timer = 0
				print("SCENE TRANSITION NOW")
				#CHASE PUT SCENE TRANSITION HERE IF YOU WANT A DELAY

func _physics_process(delta: float) -> void:
	match current_state:
		STATE.None:
			pass
		STATE.Player:
			if Input.is_action_just_released("click") and ready_to_throw:
				#Release mouse draw line
				canvas.reset_end_point()
				
				#Set Variables
				pong_ball.freeze = false
				ready_to_throw = false
				
				#Get Mouse Delta
				var mouse_delta_vector = canvas.get_global_mouse_position() - start_point
				var force_vector = Vector2(mouse_delta_vector.x / canvas.get_viewport_rect().size.x, mouse_delta_vector.y / canvas.get_viewport_rect().size.y)
				
				#Get Force Amount
				var throw_force = default_throw_force * force_vector.length()
				
				#Get Force Direction
				force_vector = force_vector.normalized()
				var throw_direction = Vector3(force_vector.x, 0, force_vector.y)

				#Apply Impulse
				pong_ball.apply_impulse(table.basis.y * default_up_force)
				pong_ball.apply_impulse(throw_direction * throw_force)
				
				#Next State
				player_balls_left = player_balls_left - 1
				setup_state(STATE.Wait)
		STATE.Enemy:
			pass
		STATE.End:
			pass
	

func setup_state(next_state: STATE) :
	#End Current State
	match current_state:
		STATE.Wait:
			point_scored = false
			#Turn off player stuff
			if state_before_wait == STATE.Player:
				player_move_display.text = ""
			
			#END GAME IF EMPTY
			if player_cups.is_empty(): 
				next_state = STATE.End
				winner = "player"
			if enemy_cups.is_empty():
				next_state = STATE.End
				winner = "opponent"
		STATE.Transition:
			if state_before_wait == STATE.Enemy:
				canvas.toggle_opponent_view(false)
				current_enemy_move = current_enemy_move + 1
				enemy_move_display.text = "Enemy Move: " + str(current_enemy_move)
	
	#Setup Next State
	match next_state:
		STATE.None:
			state_display.text = "Current State: None"
		STATE.Player:
			pong_ball.toggle_bounce(true)
			pong_ball.freeze_at_location(ball_start.position, ball_start.rotation)
			
			canvas.update_ball_display(player_balls_left)
			ready_to_throw = false
			state_display.text = "Current State: Player"
		STATE.Wait:
			wait_timer = 0
			state_before_wait = current_state
		STATE.Transition:
			wait_timer = 0
		STATE.Enemy:
			wait_timer = 0
			canvas.toggle_opponent_view(true)
			pong_ball.toggle_bounce(true)
			pong_ball.freeze_at_location(ball_idle.position, ball_idle.rotation)
			state_display.text = "Current State: Enemy"
		STATE.End:
			wait_timer = 0
			state_display.text = "Current State: End"
			canvas.display_message("GAME OVER")
			#CHASE START SCENE TRANSITION HERE. PUT A WAIT TIMER IN WAIT IF YOU WANT A DELAY
			pass
	
	current_state = next_state

#Called in _process wait, processes wait functions
func process_wait() -> void:
	if state_before_wait == STATE.Player:
		if player_balls_left > 0:
			setup_state(STATE.Player)
		else:
			player_balls_left = 2
			setup_state(STATE.Enemy)
	elif state_before_wait == STATE.Enemy:
		state_after_transition = STATE.Player
		setup_state(STATE.Transition)

#Called in solo_cup
func destroy_player_cup(player_cup: Node3D) -> void:
	point_scored = true
	canvas.display_timed_message("BALL BACK", 1)
	player_cups.erase(player_cup)
	
	player_balls_left = player_balls_left + 1
	canvas.update_ball_display(player_balls_left)
	pong_ball.freeze_at_location(ball_idle.position, ball_idle.rotation)

#Called in solo_cup
func destroy_opponent_cup(opponent_cup: Node3D) -> void:
	enemy_cups.erase(opponent_cup)
	canvas.display_message("OPPONENT POINT")
	point_scored = true
	wait_timer = 0
	pong_ball.freeze_at_location(ball_idle.position, ball_idle.rotation)

#Called in enemy
func spawn_opponent_miss() -> void:
	var release_position = opponent_miss.position + Vector3(0,2,0)
	pong_ball.release_at_location(release_position, ball_start.rotation)

#Called in enemy
func spawn_random_opponent_throw() -> void:
	if enemy_cups.is_empty():
		print("tried to destroy nonexistant enemy cup")
		return
	
	point_scored = true
	var current_cup = enemy_cups.pick_random()
	var release_position = current_cup.global_position + Vector3(0,2,0)
	pong_ball.release_at_location(release_position, ball_start.rotation)
