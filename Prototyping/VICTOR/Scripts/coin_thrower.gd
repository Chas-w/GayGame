extends Sprite2D

var mouse_down : bool
var ready_to_throw : bool

@export_category("References")
@export var start_location : Node2D
@export var coin : RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_coin()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
	#Find Distance
	ready_to_throw = start_location.position.distance_to(get_local_mouse_position()) < 40
	
	#Click to start
	if Input.is_action_just_pressed("click") and ready_to_throw:
		mouse_down = true
	
	#Restart game
	if Input.is_action_just_pressed("rightclick"):
		restart_coin()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("click") and mouse_down:
		mouse_down = false
		
		var throw_distance = start_location.position.distance_to(get_local_mouse_position())
		var throw_direction : Vector2 = start_location.position - get_local_mouse_position()
		
		release_coin()
		coin.apply_impulse(throw_distance * 1.5 * throw_direction.normalized())

func _draw() -> void:
	if mouse_down:
		draw_line(start_location.position, get_local_mouse_position(), Color.WHITE, 5)

func restart_coin() -> void:
	coin.position = start_location.global_position
	coin.freeze = true

func release_coin() -> void:
	coin.freeze = false
	coin.position = start_location.global_position
