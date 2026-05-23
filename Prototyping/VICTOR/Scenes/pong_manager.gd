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

@export_group("References")
@export var ball_start : Node3D
@export var canvas : Control
@export var table : Node3D

#State Management
enum STATE {None, Player, Wait, Enemy, End}
var current_state = STATE.None
var state_after_wait : STATE

var wait_timer : float

var current_player_move : int = 0
var current_enemy_move : int = 0

#Local Variables
var ready_to_throw : bool
var start_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_state(STATE.Player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state:
		STATE.None:
			if Input.is_action_just_pressed("enter"):
				setup_state(STATE.Player)
		STATE.Player:
			#Start throwing the ball
			if Input.is_action_pressed("click") and !ready_to_throw:
				ready_to_throw = true
				start_point = canvas.get_global_mouse_position()
		STATE.Wait:
			wait_timer = wait_timer + delta
			if wait_timer > 5:
				wait_timer = 0
				current_player_move = current_player_move + 1
				setup_state(STATE.Enemy)
		STATE.Enemy:
			wait_timer = wait_timer + delta
			if wait_timer > 2:
				wait_timer = 0
				current_enemy_move = current_enemy_move + 1
				setup_state(STATE.Player)
			pass
		STATE.End:
			pass

	#Rest for debugging
	if Input.is_action_pressed("rightclick"):
		pong_ball.freeze = true
		pong_ball.position = ball_start.position
		pong_ball.rotation = ball_start.rotation


func _physics_process(delta: float) -> void:
	match current_state:
		STATE.None:
			pass
		STATE.Player:
			if Input.is_action_just_released("click") and ready_to_throw:
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
	match next_state:
		STATE.None:
			pass
		STATE.Player:
			pong_ball.freeze = true
			pong_ball.position = ball_start.position
			pong_ball.rotation = ball_start.rotation
			
			ready_to_throw = false
		STATE.Enemy:
			print(current_enemy_move)
			print(enemy_moves.size())
			if current_enemy_move < enemy_moves.size() - 1:
				if enemy_moves[current_enemy_move] and !enemy_cups.is_empty():
					destroy_random_enemy()
				else:
					print("enemy missed")
			else:
				print("invalid enemy move")
			
		STATE.End:
			pass
	
	current_state = next_state

func destroy_random_enemy() -> void:
	if enemy_cups.is_empty():
		print("tried to destroy nonexistant enemy cup")
		return
	
	var current_cup = enemy_cups.pick_random()
	enemy_cups.erase(current_cup)
	current_cup.queue_free()
