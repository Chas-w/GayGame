extends Node3D

#Serialize Variables
@export_group("Attributes")
@export var pong_ball : RigidBody3D
@export var spare_ball : MeshInstance3D
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
@export var table : Node3D
@export var opponent : Node3D

#State Management
enum STATE {None, Player, Wait, Enemy, End}
var current_state = STATE.None
var state_after_wait : STATE

var wait_timer : float

var current_player_move : int = 0
var current_enemy_move : int = 0

var current_player_turn : int = 0
var player_balls_left : int = 0

#Local Variables
var ready_to_throw : bool
var start_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set Manager in Player Cups
	for i in range(player_cups.size()):
		player_cups[i].manager = self
	for i in range(enemy_cups.size()):
		enemy_cups[i].manager = self
	
	#Setup display
	result_display.text = ""
	#pong_ball.physics_material_override
	
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
			#Start throwing the ball
			if Input.is_action_pressed("click") and !ready_to_throw:
				ready_to_throw = true
				start_point = canvas.get_global_mouse_position()
				canvas.set_start_point()
			if ready_to_throw:
				canvas.update_end_point()
		STATE.Wait:
			#Track wait_time
			wait_timer = wait_timer + delta
			if wait_timer > 5:
				wait_timer = 0
				if current_player_turn < 1:
					current_player_turn = current_player_turn + 1
					spare_ball.visible = false
					setup_state(STATE.Player)
				else:
					setup_state(STATE.Enemy)
			
			#Make sure ball is in the right place
			if pong_ball.position.y < -3 or pong_ball.position.y > 3:
				move_ball_to_idle()
				wait_timer = 5
		STATE.Enemy:
			wait_timer = wait_timer + delta
			if wait_timer > 5:
				wait_timer = 0
				canvas.display_message("OPPONENT MISS")
				setup_state(STATE.Player)
			elif pong_ball.position.y < -3 or pong_ball.position.y > 3:
				move_ball_to_idle()
				wait_timer = 5
			pass
		STATE.End:
			#Rest for debugging
			if Input.is_action_pressed("rightclick"):
				pong_ball.freeze = true
				pong_ball.position = ball_start.position
				pong_ball.rotation = ball_start.rotation
			pass
	
	#MANAGE DISPLAY FUNCTIONS
	


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
			current_player_turn = 0
			spare_ball.visible = true
			opponent.switch_to_idle()
			result_display.text = ""
			
			current_enemy_move = current_enemy_move + 1
			enemy_move_display.text = "Enemy Move: " + str(current_enemy_move)
		STATE.Wait:
			pass
		STATE.Player:
			pass
		STATE.End:
			pass
	
	#Setup Next State
	match next_state:
		STATE.None:
			state_display.text = "Current State: None"
		STATE.Player:
			pong_ball.freeze = true
			pong_ball.toggle_bounce(true)
			pong_ball.position = ball_start.position
			pong_ball.rotation = ball_start.rotation
			
			ready_to_throw = false
			state_display.text = "Current State: Player"
		STATE.Wait:
			pass
		STATE.Enemy:
			opponent.switch_to_throw()
			
			current_player_move = current_player_move + 1
			player_move_display.text = "Player Move: " + str(current_player_move)
			
			if current_enemy_move < enemy_moves.size() - 1:
				if enemy_moves[current_enemy_move] and !enemy_cups.is_empty():
					spawn_random_opponent_throw()
				else:
					print("enemy missed")
			else:
				print("invalid enemy move")
			state_display.text = "Current State: Enemy"
		STATE.End:
			state_display.text = "Current State: End"
			pass
	
	current_state = next_state

#Called in solo_cup
func destroy_player_cup(player_cup: Node3D) -> void:
	player_cups.erase(player_cup)
	current_player_turn = current_player_turn - 1
	setup_state(STATE.Player)

#Move ball into an idle holding position
func move_ball_to_idle() -> void:
	pong_ball.freeze = true
	pong_ball.position = ball_idle.position
	pong_ball.rotation = ball_idle.rotation

#Move ball to start
func move_ball_to_start() -> void:
	pong_ball.freeze = true
	pong_ball.position = ball_start.position
	pong_ball.rotation = ball_start.rotation


func release_ball_at_position(release_position: Vector3) -> void:
	pong_ball.position = release_position
	pong_ball.freeze = false

func destroy_opponent_cup(opponent_cup: Node3D) -> void:
	enemy_cups.erase(opponent_cup)
	canvas.display_message("OPPONENT POINT")
	setup_state(STATE.Player)

func spawn_random_opponent_throw() -> void:
	if enemy_cups.is_empty():
		print("tried to destroy nonexistant enemy cup")
		return
	
	var current_cup = enemy_cups.pick_random()
	var release_position = current_cup.global_position + Vector3(0,2,0)
	release_ball_at_position(release_position)
	
func destroy_random_enemy() -> void:
	if enemy_cups.is_empty():
		print("tried to destroy nonexistant enemy cup")
		return
	
	var current_cup = enemy_cups.pick_random()
	enemy_cups.erase(current_cup)
	current_cup.queue_free()
