extends Node3D

@export_category("Controls")
@export_range(0,1) var control_scheme : int

@export_category("References")
@export var match : Node3D
@export var hand_pivot : Node3D
@export var text_display : Label

@export_category("Attributes")
@export var light_time : float
var light_timer : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand_pivot.control_scheme = control_scheme

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var hand_direction = hand_pivot.rotation_degrees.z
	if hand_direction < 0:
		hand_direction = 360 + hand_direction
	if match.is_lit :
		text_display.text = "Fire Direction: " + str(match.fire_sprite.rotation_degrees.z) + "\n" + "Hand Direction: " + str(hand_direction)
		if abs(match.fire_sprite.rotation_degrees.z - hand_direction) <= 20 :
			text_display.text = "LIGHTING"
	else :
		text_display.text = ""
