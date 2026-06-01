extends Node3D

@export_category("Opponent Cameras")
@export var opponent_turn : Control

@export_category("Opponent Visuals")
@export var idle_arms : Node3D
@export var throw_arms : Node3D

var throw_timer : float = 0
var has_thrown : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_thrown:
		throw_timer = throw_timer + delta
		if throw_timer > 1:
			switch_to_idle()
			throw_timer = 0
			has_thrown = true

#Show idle arms (SWITCH TO ANIMATION)
func switch_to_idle() -> void:
	idle_arms.visible = true
	throw_arms.visible = false

#Show throw arms (SWITCH TO ANIMATION)
func switch_to_throw() -> void:
	idle_arms.visible = false
	throw_arms.visible = true
	
	#start timer to deactivate arms
	has_thrown = true
	throw_timer = 0
