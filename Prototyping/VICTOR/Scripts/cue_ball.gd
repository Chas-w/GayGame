extends RigidBody3D
@export var action_cam : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#action_cam.global_position.x = global_position.x - .25
	print(abs(Vector3(0,0,0).distance_to(linear_velocity)))
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		#apply_impulse(Vector3(1,0,0) * 4)
		pass
