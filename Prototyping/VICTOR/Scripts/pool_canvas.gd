extends Control

@export_category("UI Elements")
@export var moves_remaining_display : Control
@export var pool_cue : Sprite2D
@export var pool_pivot : Node2D

#Manager
var pool_manager

#Line Variables
var start_point : Vector2
var end_point : Vector2
var retract_line : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pool_pivot.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	#Line retracts after player lets go
	if retract_line:
		if end_point != start_point:
			end_point = end_point.move_toward(start_point, 10)
			pool_pivot.position = end_point
		else:
			end_point = start_point
			pool_pivot.visible = false
			retract_line = false
			
			#Shoot the ball
			pool_manager.hit_ball()
	#Rotate pool cue
	if start_point != end_point:
		pool_pivot.look_at(start_point)
		pool_pivot.rotate(PI/2)

func _draw() -> void:
	if start_point != end_point:
		draw_line(start_point, end_point, Color.WHITE, 5)
		
		#var target_direction = (end_point - start_point).normalized()
		#var target_distance = end_point.distance_to(start_point)
		#draw_line(end_point, end_point - target_direction * 5, Color.WHITE, 2)
		#print(end_point)
		#print(end_point + target_direction * 6)

func update_move_display(move_num : int) -> void:
	moves_remaining_display.text = "Moves Remaining: " + str(move_num)

#region line functions
func update_start_point() -> void:
	start_point = get_local_mouse_position()
	pool_pivot.position = get_local_mouse_position()
	pool_pivot.visible = true

func update_end_point() -> void:
	end_point = get_local_mouse_position()
	pool_pivot.position = get_local_mouse_position()

func get_aim_distance() -> float:
	return abs(start_point.distance_to(end_point))

func get_aim_vector() -> Vector2:
	return (start_point - end_point).normalized()

func release_line() -> void:
	retract_line = true
#endregion
