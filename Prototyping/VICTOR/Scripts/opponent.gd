extends Node3D

@export_category("Opponent Cameras")
@export var opponent_turn : Control

@export_category("Opponent Visuals")
@export var idle_arms : Node3D
@export var throw_arms : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Show Opponent View Cameras
func toggle_opponent_view(toggle: bool) -> void:
	opponent_turn.visible = toggle

#Show idle arms (SWITCH TO ANIMATION)
func switch_to_idle() -> void:
	idle_arms.visible = true
	throw_arms.visible = false
	#opponent_turn.visible = false

#Show throw arms (SWITCH TO ANIMATION)
func switch_to_throw() -> void:
	idle_arms.visible = false
	throw_arms.visible = true
	#opponent_turn.visible = true
