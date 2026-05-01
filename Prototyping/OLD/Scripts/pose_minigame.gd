extends Node3D

@export var move_force : float

var is_posing : bool
var rigid_array : Array[RigidBody3D]

@onready var left_hand = $LeftArm/LeftHand
@onready var right_hand = $RightArm/RightHand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rigid_array = [$LeftArm/LeftUpperArm, $LeftArm/LeftLowerArm, $LeftArm/LeftHand, $RightArm/RightUpperArm, $RightArm/RightLowerArm, $RightArm/RightHand]
	_freeze_rigidbodies(true)
	
	left_hand.move_force = move_force
	right_hand.move_force = move_force

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func toggle_posing(toggle : bool) -> void:
	is_posing = toggle
	left_hand.is_posing = is_posing
	right_hand.is_posing = is_posing
	_freeze_rigidbodies(!is_posing)

func _freeze_rigidbodies(toggle : bool) -> void:
	for i in range(rigid_array.size()) :
		rigid_array[i].freeze = toggle
