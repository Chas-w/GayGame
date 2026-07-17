extends RigidBody3D

@export var rotation_speed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	#add_constant_torque(Vector3(0,1,0) * rotation_speed)
	angular_velocity = Vector3(0,1,0) * rotation_speed
