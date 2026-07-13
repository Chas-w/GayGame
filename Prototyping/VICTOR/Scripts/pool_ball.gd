extends RigidBody3D

enum TYPE {Cue, Player, Enemy}
@export var identity : TYPE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_velocity() -> float:
	return abs(Vector3(0,0,0).distance_to(linear_velocity))

func reset_velocity() -> void:
	linear_velocity = Vector3(0,0,0)
