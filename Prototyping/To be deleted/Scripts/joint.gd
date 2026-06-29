extends Node3D

@export var hit_pose : bool
@export var rotation_speed : float
@export var sprite : Sprite3D
@export var rotation_positions : Array[Vector3]
@export var current_rotation : int
@export var mirror_joint : Node3D
var can_rotate : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !hit_pose :
		handle_rotation(delta)
	else:
		hit_rotation()

func random_rotate() -> void:
	current_rotation = randi_range(0, rotation_positions.size()-1)
	rotation_degrees = rotation_positions[current_rotation]

func hit_rotation() -> void:
	if !can_rotate :
		return
	if Input.is_action_just_pressed("up"):
		current_rotation += 1
		if current_rotation >= rotation_positions.size() :
			current_rotation = rotation_positions.size() - 1
		rotation_degrees = rotation_positions[current_rotation]
		mirror_joint.rotation_degrees = rotation_positions[current_rotation] + Vector3(0,0, 180)
	if Input.is_action_just_pressed("down"):
		current_rotation -= 1
		if current_rotation <= 0 :
			current_rotation = 0
		rotation_degrees = rotation_positions[current_rotation]
		mirror_joint.rotation_degrees = rotation_positions[current_rotation] + Vector3(0,0, 180)

func handle_rotation(delta : float) -> void:
	if !can_rotate :
		return
	if Input.is_action_pressed("up"):
		rotate(basis.z, rotation_speed * delta)
	if Input.is_action_pressed("down"):
		rotate(-basis.z, rotation_speed * delta)

func toggle_limb(toggle : bool) -> void:
	if toggle :
		can_rotate = true
		if(sprite != null):
			sprite.modulate = Color(1.0, 0.0, 1.0, 1.0)
	else :
		can_rotate = false
		if(sprite != null):
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
