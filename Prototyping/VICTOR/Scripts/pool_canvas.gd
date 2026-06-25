extends Control

var retract_line : bool

var start_point : Vector2
var end_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	#Line retracts after player lets go
	if retract_line:
		if end_point != start_point:
			end_point = end_point.move_toward(start_point, 22)
		else:
			end_point = start_point
			retract_line = false

func _draw() -> void:
	if start_point != end_point:
		draw_line(start_point, end_point, Color.WHITE, 5)

func update_start_point() -> void:
	start_point = get_local_mouse_position()

func update_end_point() -> void:
	end_point = get_local_mouse_position()

func get_aim_distance() -> float:
	return abs(start_point.distance_to(end_point))

func get_aim_vector() -> Vector2:
	return (start_point - end_point).normalized()

func release_line() -> void:
	retract_line = true
