extends RigidBody3D

#Attributes
@export var is_camera_left : bool
@export var move_force : float

#Variables
var is_posing : bool
var is_mouse_down : bool
var anchor_position : Vector3

#References
@onready var torso := $"../../Torso"
@onready var camera := $"../../Camera3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (is_camera_left and event.button_index == MOUSE_BUTTON_LEFT) or (!is_camera_left and event.button_index == MOUSE_BUTTON_RIGHT):
			if event.is_pressed():
				is_mouse_down = true
				anchor_position = camera.shoot_ray()
				if anchor_position == null:
					is_mouse_down = false
			elif event.is_released():
				is_mouse_down = false

func _physics_process(delta: float) -> void:
	if is_posing and is_mouse_down:
		_handle_mouse_anchors()
	#if is_posing:
		#_handle_movement()

func _handle_mouse_anchors() -> void:
	apply_force((anchor_position - global_position) * move_force)

func _handle_movement() -> void:
	if is_camera_left :
		if Input.is_key_pressed(KEY_D):
			apply_force(torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_A):
			apply_force(-torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_W):
			apply_force(torso.transform.basis.y * move_force)
	else:
		if Input.is_key_pressed(KEY_L):
			apply_force(torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_J):
			apply_force(-torso.transform.basis.x * move_force)
		if Input.is_key_pressed(KEY_I):
			apply_force(torso.transform.basis.y * move_force)
