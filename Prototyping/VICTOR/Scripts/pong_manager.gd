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
enum STATE {None, Player, Wait, Enemy, End}
var current_state = STATE.None
var state_before_wait : STATE

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
				process_wait()
				
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
			#Rest for debugging
			if Input.is_action_pressed("rightclick"):
				pong_ball.freeze_at_location(ball_start.position, ball_start.rotation)
			pass

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
				update_spare_balls()
				setup_state(STATE.Wait)
		STATE.Enemy:
			pass
		STATE.End:
			pass
	

func setup_state(next_state: STATE) :
	#End Current State
	match current_state:
		STATE.None:
			pass
		STATE.Enemy:
			pass
			#current_player_turn = 0
			#spare_ball.visible = true
		STATE.Wait:
			point_scored = false
			#Turn off enemy stuff
			if state_before_wait == STATE.Enemy:
				opponent.switch_to_idle()
				opponent.toggle_opponent_view(false)
				current_enemy_move = current_enemy_move + 1
				enemy_move_display.text = "Enemy Move: " + str(current_enemy_move)
			#Turn off player stuff
			if state_before_wait == STATE.Player:
				player_move_display.text = ""
			
			#END GAME IF EMPTY
			if player_cups.is_empty() or enemy_cups.is_empty():
				next_state = STATE.End
		STATE.Player:
			pass
	
	#Setup Next State
	match next_state:
		STATE.None:
			state_display.text = "Current State: None"
		STATE.Player:
			pong_ball.toggle_bounce(true)
			pong_ball.freeze_at_location(ball_start.position, ball_start.rotation)
			
			update_spare_balls()
			ready_to_throw = false
			state_display.text = "Current State: Player"
		STATE.Wait:
			wait_timer = 0
			state_before_wait = current_state
		STATE.Enemy:
			opponent.toggle_opponent_view(true)
			
			pong_ball.toggle_bounce(true)
			pong_ball.freeze_at_location(ball_idle.position, ball_idle.rotation)
			state_display.text = "Current State: Enemy"
		STATE.End:
			state_display.text = "Current State: End"
			canvas.display_message("GAME OVER")
			pass
	
	current_state = next_state

#Called in _process wait, processes wait functions
func process_wait() -> void:
	update_spare_balls()
	if state_before_wait == STATE.Player:
		if player_balls_left > 0:
			setup_state(STATE.Player)
		else:
			player_balls_left = 2
			setup_state(STATE.Enemy)
	elif state_before_wait == STATE.Enemy:
		setup_state(STATE.Player)

func update_spare_balls() -> void:
	pass
	#CODE NOT WORKING
	#for i in range(spare_balls.size() - 1):
		#spare_balls[i].queue_free()
	#spare_balls.clear()
	#
	#var spawn_position = ball_start.position + Vector3(-0.5, 0, 0)
	#for i in range(player_balls_left-1):
		#var new_spare = spare_prefab.instantiate()
		#new_spare.position = spawn_position - Vector3(0.25, 0, 0) * i
		#add_child(new_spare)
		#spare_balls.append(new_spare)

#Called in solo_cup
func destroy_player_cup(player_cup: Node3D) -> void:
	point_scored = true
	canvas.display_message("BALL BACK")
	player_cups.erase(player_cup)
	
	player_balls_left = player_balls_left + 1
	pong_ball.freeze_at_location(ball_idle.position, ball_idle.rotation)

func destroy_opponent_cup(opponent_cup: Node3D) -> void:
	enemy_cups.erase(opponent_cup)
	point_scored = true
	wait_timer = 0
	pong_ball.freeze_at_location(ball_idle.position, ball_idle.rotation)

func spawn_opponent_miss() -> void:
	canvas.display_message("OPPONENT MISS")
	var release_position = opponent_miss.position + Vector3(0,2,0)
	pong_ball.release_at_location(release_position, ball_start.rotation)

func spawn_random_opponent_throw() -> void:
	if enemy_cups.is_empty():
		print("tried to destroy nonexistant enemy cup")
		return
	
	point_scored = true
	wait_timer = 0
	var current_cup = enemy_cups.pick_random()
	var release_position = current_cup.global_position + Vector3(0,2,0)
	pong_ball.release_at_location(release_position, ball_start.rotation)
