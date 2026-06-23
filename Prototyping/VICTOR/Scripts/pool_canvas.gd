extends Control

var retract_line : bool

var start_point : Vector2
var end_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Line retracts after player lets go
	if retract_line:
		if end_point != start_point:
			queue_redraw()
			start_point = start_point.move_toward(end_point, 22)
		else:
			queue_redraw()
			end_point = start_point
			retract_line = false

func _draw() -> void:
	pass
