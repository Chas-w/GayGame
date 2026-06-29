extends Node3D

@export var rotation_speed : float
var control_scheme : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match control_scheme:
		0:
			if Input.is_action_pressed("up"):
				rotate(-basis.z, rotation_speed * delta)
			if Input.is_action_pressed("down"):
				rotate(basis.z, rotation_speed * delta)
		1:
			if Input.is_action_pressed("up_1"):
				rotate(-basis.z, rotation_speed * delta)
			if Input.is_action_pressed("down_1"):
				rotate(basis.z, rotation_speed * delta)
