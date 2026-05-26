extends Control

@export_category("References")
@export var player_action_view : Control
@export var result_display : Label

#Line Drawing
var start_point : Vector2
var end_point : Vector2
var retract_line : bool

#Message Display
var message_display_timer: float
var message_display_time: float = 2
var message_displayed: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

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
	
	#Display opponent result message on screen
	if message_displayed:
		message_display_timer = message_display_timer + delta
		if message_display_timer > message_display_time:
			result_display.text = ""
			message_display_timer = 0
			message_displayed = false

func _draw() -> void:
	if end_point != start_point:
		#draw line
		draw_line(start_point, end_point, Color.WHITE, 5)
		#draw circle
		draw_circle(end_point, 10, Color.WHITE)
		draw_circle(start_point, 2.5, Color.WHITE)

#Line Drawing
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
	#end_point = start_point
	retract_line = true
	player_action_view.visible = false


#Message Display
func display_message(message: String) -> void:
	message_displayed = true
	result_display.text = message
	print("displaying message")
