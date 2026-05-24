extends CharacterBody3D
#https://youtu.be/KT06pv06Q1U?si=Oyfxr4sBKFvDll4p
@export_category("Movement Stuff")
@export var nav_agent : NavigationAgent3D
@export var rotation_speed : float
@export var move_speed : float
@export var temp_visualizer : Node3D #to be used in dev time to check where the player is clicking

@export_category("Cam Stuff")
@export var cam : Camera3D
@export var environment_cam : PhantomCamera3D
@export var fp_cam : PhantomCamera3D
@export var digi_manager : Node3D
var toggle_digi : bool 
var timer : float
var crt_ready : bool 

@export_category("State Machines")
enum Move_State{FIRST_PERSON,POINT_AND_CLICK, MOVE_NULL}
@export var move_state : Move_State = Move_State.POINT_AND_CLICK
enum FP_State{FP_IDLE, FP_WALK, FP_DIGI, FP_NULL}
@export var fp_state : FP_State = FP_State.FP_DIGI
enum PC_State{PC_IDLE, PC_WALK, PC_NULL}
@export var pc_state : PC_State = PC_State.PC_IDLE
var trigger_click_movement : bool

func _process(delta):
	if (Input.is_action_just_pressed("enter")): #this is where we toggle from fp view and pc view
		#toggle between point and click and first person
		if (move_state == Move_State.POINT_AND_CLICK):
			_set_pc_state(PC_State.PC_NULL)
			_set_move_state(Move_State.FIRST_PERSON)
			_set_fp_state(FP_State.FP_DIGI)
		elif(move_state == Move_State.FIRST_PERSON):
			_set_fp_state(FP_State.FP_NULL)
			_set_move_state(Move_State.POINT_AND_CLICK)
			_set_pc_state(PC_State.PC_IDLE)
			digi_manager.toggle_digi = false
		timer = 0

	if (move_state == Move_State.POINT_AND_CLICK):
		#region PC Camera
		digi_manager.crt_ready = false
		fp_cam.priority = 0
		environment_cam.priority = 100
		cam.set_orthogonal(25,.05,4000)
		#endregion
		#enable nav agent
		if (pc_state == PC_State.PC_IDLE):
			pass
		elif (pc_state == PC_State.PC_WALK):
			if (nav_agent.is_navigation_finished()):
				return
				#go to idle state
			else:
				_move_to_target(delta,move_speed)
		elif (pc_state == PC_State.PC_NULL):
			pass

	if (move_state == Move_State.FIRST_PERSON):
		#disable nav agent? 
		#region FP Camera
		timer += delta
		if (timer >= (fp_cam.tween_duration -.1)):
			digi_manager.crt_ready = true
		fp_cam.priority = 100
		environment_cam.priority = 0
		cam.set_perspective(50,.05,4000)
		#endregion
		if (fp_state == FP_State.FP_IDLE):
			pass
		elif (fp_state == FP_State.FP_WALK):
			#first person walking
			pass
		elif (fp_state == FP_State.FP_DIGI):
			digi_manager.toggle_digi = true
			pass
		elif (fp_state == FP_State.FP_NULL):
			digi_manager.toggle_digi = false
##region Applying Point and Click Movement
		#nav_agent.set_target_position(position) #stop the movement, reset the target position
		#temp_visualizer.position = position
##endregion

func _move_to_target(delta,speed): #setting point and click movement parameters
	var target_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	#region Rotate To Look At Target
	var target2D : Vector2 = Vector2(target_position.x, target_position.z)
	var player2D : Vector2 = Vector2(global_position.x, global_position.z)
	var face_direction = -(target2D - player2D)
	rotation.y = lerp_angle(rotation.y, atan2(face_direction.x, face_direction.y), delta * rotation_speed)
	
#endregion
	velocity = direction * speed
	move_and_slide()

#region Set States
func _set_move_state(next_move_state:int):
	var prev_move_state := move_state
	move_state = next_move_state
func _set_pc_state(next_pc_state:int):
	var prev_pc_state := pc_state
	pc_state = next_pc_state
func _set_fp_state(next_fp_state:int):
	var prev_fp_state := fp_state
	fp_state = next_fp_state
#endregion

func _input(event):
	#region Checking for Point and Click Ability
	if(Input.is_action_just_pressed("click") && (move_state == Move_State.POINT_AND_CLICK)):
		var mouse_pos = get_viewport().get_mouse_position() #mouse position translated to WHERE in the viewport the mouse clicked
		var ray_length = 1000 #length of raycast shot from mouse position
		var from = cam.project_ray_origin(mouse_pos) #starting position of raycast
		var to = from + cam.project_ray_normal(mouse_pos) * ray_length #target of raycast
		var space = get_world_3d().direct_space_state #where raycast is being translated from
		var ray_query = PhysicsRayQueryParameters3D.new() #new raycast
		ray_query.from = from
		ray_query.to = to
		var result = space.intersect_ray(ray_query) #where the raycast intersects with an object
		temp_visualizer.position = (result.position) #set visualizer for devs
		nav_agent.set_target_position(result.position) #apply navigation
		#go to pc_walk 
		_set_pc_state(PC_State.PC_WALK)
	#endregion
