extends Control

@export var player_action_view : Control
var start_point : Vector2
var end_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	if end_point != start_point:
		draw_line(start_point, end_point, Color.WHITE, 5)

func set_start_point() -> void:
	queue_redraw()
	start_point = get_global_mouse_position()
	reset_end_point()

func update_end_point() -> void:
	queue_redraw()
	end_point = get_global_mouse_position()
	if !player_action_view.visible:
		player_action_view.visible = true

func reset_end_point() -> void:
	queue_redraw()
	end_point = start_point
	player_action_view.visible = false
