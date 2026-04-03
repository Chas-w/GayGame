extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#Attributes
@export var sens = 0.5

#References
@onready var pivot = $CameraOrigin
@onready var left_hand = $LeftArm/LeftHand
@onready var right_hand = $RightArm/RightHand

#Posing Variables
var is_posing = false
var rigid_array : Array[RigidBody3D]

func _ready() -> void:
	#Set up array
	rigid_array = [$LeftArm/LeftUpperArm, $LeftArm/LeftLowerArm, $LeftArm/LeftHand, $RightArm/RightUpperArm, $RightArm/RightLowerArm, $RightArm/RightHand]
	
	#Should not start posing
	_toggle_posing(false)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !is_posing:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("pose"):
		_toggle_posing(!is_posing)

func _physics_process(delta: float) -> void:
	if !is_posing:
		_handle_movement()
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _handle_movement() -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func _toggle_posing(toggle : bool) -> void:
	#Set posing
	is_posing = toggle
	left_hand.is_posing = toggle
	right_hand.is_posing = toggle
	
	#Set mouse
	if is_posing:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#Freeze rigidbodies
	_freeze_rigidbodies(!toggle)

func _freeze_rigidbodies(toggle : bool) -> void:
	for i in range(rigid_array.size()) :
		rigid_array[i].freeze = toggle
	
