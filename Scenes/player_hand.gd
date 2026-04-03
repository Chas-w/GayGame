extends RigidBody3D

@export var is_camera_left : bool
@export var move_force : float
var is_posing : bool
var torso

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if is_posing:
		_handle_movement()

func _handle_movement() -> void:
	if is_camera_left :
		#if Input.is_key_pressed(KEY_D):
			#apply_force(Vector3.RIGHT * move_force)
		#if Input.is_key_pressed(KEY_A):
			#apply_force(Vector3.LEFT * move_force)
		#if Input.is_key_pressed(KEY_W):
			#apply_force(Vector3.UP * move_force)
		
		if Input.is_key_pressed(KEY_D):
			apply_force(torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_A):
			apply_force(-torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_W):
			apply_force(torso.transform.basis.y * move_force)
	else:
		#if Input.is_key_pressed(KEY_L):
			#apply_force(Vector3.RIGHT * move_force)
		#if Input.is_key_pressed(KEY_J):
			#apply_force(Vector3.LEFT * move_force)
		#if Input.is_key_pressed(KEY_I):
			#apply_force(Vector3.UP * move_force)
			
		if Input.is_key_pressed(KEY_L):
			apply_force(torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_J):
			apply_force(-torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_I):
			apply_force(torso.transform.basis.y * move_force)
