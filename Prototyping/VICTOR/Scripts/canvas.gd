extends Control

@export_category("Ball and Line References")
@export var player_action_view : Control
@export var result_display : Label
@export var ball_sprites : Array[Sprite2D]

@export_category("Opponent Turn References")
@export var view_move_speed: float
@export var opponent_view: SubViewportContainer
@export var opponent_cup_view: SubViewportContainer
@export var opponent_view_positions: Array[Control]
@export var opponent_cup_view_positions: Array[Control]

#Line Drawing
var start_point : Vector2
var end_point : Vector2
var retract_line : bool

#Message Display
var message_display_timer: float
var message_display_time: float = 2
var message_displayed: bool

#Ball Display
var current_balls_displayed: int

#Opponent Turn View
var current_ovp: int #opponent_view_position
var move_opponent_view: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_ball_display()

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
	
	#Move opponent view into frame
	if move_opponent_view:
		var opponent_view_check = opponent_view.position == opponent_view_positions[current_ovp].position
		var opponent_cup_check = opponent_cup_view.position == opponent_cup_view_positions[current_ovp].position
		#Move opponent views to correct spot
		if !opponent_view_check:
			opponent_view.position = opponent_view.position.move_toward(opponent_view_positions[current_ovp].position, 10)
		if !opponent_cup_check:
			opponent_cup_view.position = opponent_cup_view.position.move_toward(opponent_cup_view_positions[current_ovp].position, 10)
		if opponent_view_check && opponent_cup_check:
			move_opponent_view = false

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
	message_display_time = 2

func display_timed_message(message: String, display_time: float) -> void:
	message_displayed = true
	result_display.text = message
	message_display_time = display_time

#Update the amount of balls shown
func update_ball_display(ball_num: int) -> void:
	#Reset ball display to show correct amount
	reset_ball_display()
	#Check if no balls need to be shown
	if ball_num == 1:
		return
	#Show correct ball amount
	for i in range(ball_num - 1):
		ball_sprites[i].visible = true
	#Track current balls displayed for future use
	current_balls_displayed = ball_num - 1

#Reset the amount of balls shown
func reset_ball_display()->void:
	for i in range(ball_sprites.size()):
		ball_sprites[i].visible = false

func toggle_opponent_view(toggle: bool)->void:
	if toggle:
		current_ovp = 1
	else:
		current_ovp = 0
	move_opponent_view = true
