extends RigidBody3D

@export var is_camera_left : bool
var is_posing
@onready var playerScript = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_D):
		apply_force(Vector3.RIGHT * 50)
	if Input.is_key_pressed(KEY_A):
		apply_force(Vector3.LEFT * 50)
	if Input.is_key_pressed(KEY_W):
		apply_force(Vector3.UP * 50)
