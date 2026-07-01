extends RigidBody3D
@export var action_cam : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_velocity() -> float:
	return abs(Vector3(0,0,0).distance_to(linear_velocity))

func reset_velocity() -> void:
	linear_velocity = Vector3(0,0,0)
