extends CharacterBody3D
#https://youtu.be/KT06pv06Q1U?si=Oyfxr4sBKFvDll4
@export_category("Movement Variables")
@export var nav_agent : NavigationAgent3D
@export var rotation_speed : float
@export var move_speed : float
@export var temp_visualizer : Node3D #to be used in dev time to check where the player is clicking

@export_category("Movement States")
enum Move_State{DIGICAM, POINT_AND_CLICK, CHATTING, INSPECTING, IN_MENU, MOVE_NULL}
@export var move_state : Move_State = Move_State.POINT_AND_CLICK
enum PC_State{PC_WALK, PC_NULL}
@export var pc_state : PC_State = PC_State.PC_WALK


@export_category("Camera Variables")
@export var cam : Camera3D
@export var digi_manager : Node3D
@export var environment_cam : PhantomCamera3D
@export var fp_cam : PhantomCamera3D
@export var fp_rotation_speed : float
@export var rotation_target : Node3D
var timer : float

func _process(delta):
	match(move_state):
		Move_State.POINT_AND_CLICK:
			match(pc_state):
				PC_State.PC_WALK:
					#region Applying Point and Click Movement
					if (!digi_manager.toggle_digi): #as long as the camera isn't in digicam mode
						if(nav_agent.is_navigation_finished()): #if navigation is finished do NOTHING (breaks the movement loop)
							return
						else:
							_move_to_target(delta,move_speed) #otherwise, continuously move towards the target position at preset speed (move_speed)
					else:
						nav_agent.set_target_position(position) #stop the movement, reset the target position
						temp_visualizer.position = position
					#endregion
		Move_State.DIGICAM:
			timer += delta
			if (timer >= (fp_cam.tween_duration -.1)):
				digi_manager.fp_cam_set = true
			else:
				fp_cam.priority = 100
				environment_cam.priority = 0
				cam.set_perspective(50,.05,4000)
			pass
		Move_State.CHATTING:
			pass
		Move_State.INSPECTING:
			pass
		Move_State.IN_MENU:
			pass

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

#region state machines
func _set_move_state(next_move_state:int):
	var prev_move_state := move_state
	move_state = next_move_state
	
	#check last state
	match(prev_move_state):
		Move_State.DIGICAM:
			#region Reset Rotation
			rotation_target.rotation.x = 0
			rotation_target.rotation.y = 0
			rotation_target.rotation.z = 0
			#endregion
		pass
	#check upcoming state
	match(next_move_state):
		Move_State.POINT_AND_CLICK:
			#region Setup PC Camera
			digi_manager.fp_cam_set = false
			fp_cam.priority = 0
			environment_cam.priority = 100
			cam.set_orthogonal(25,.05,4000)
			#endregion
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			_set_PC_state(PC_State.PC_WALK)
		Move_State.DIGICAM:
			timer = 0
			nav_agent.set_target_position(position) #stop the movement, reset the target position
			temp_visualizer.position = position
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			_set_PC_state(PC_State.PC_NULL)
func _set_PC_state(next_PC_state:int):
	var prev_PC_state := pc_state
	pc_state = next_PC_state
	
	#check last state
	match(prev_PC_state):
		pass
	#check upcoming state
	match(next_PC_state):
		pass
	pass
#endregion

func _input(event):
	if(Input.is_action_just_pressed("digi_view")):
		digi_manager.toggle_digi = !digi_manager.toggle_digi
		if(digi_manager.toggle_digi):
			_set_move_state(Move_State.DIGICAM)
		else:
			_set_move_state(Move_State.POINT_AND_CLICK)
	#region Checking for Point and Click Ability
	if(Input.is_action_just_pressed("click") && !digi_manager.toggle_digi):
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
	#endregion
	#region FP Mouse Movement
	if (event is InputEventMouseMotion):
		if (move_state == Move_State.DIGICAM && digi_manager.toggle_digi):
			rotation_target.rotate_y(-event.relative.x * fp_rotation_speed)
			rotation_target.rotate_x(-event.relative.y * fp_rotation_speed)
			rotation_target.rotation.z = 0
			rotation_target.rotation.x = clampf(rotation_target.rotation.x, -deg_to_rad(70), deg_to_rad(70))
			rotation_target.rotation.y = clampf(rotation_target.rotation.y, -deg_to_rad(70), deg_to_rad(70))
	#endregion
	
	
	
func _ignore_this():
	#region Shit Chase Fucked Up AKA Archive
	#extends CharacterBody3D
	##https://youtu.be/KT06pv06Q1U?si=Oyfxr4sBKFvDll4p
	#@export_category("Movement Stuff")
	#@export var nav_agent : NavigationAgent3D
	#@export var rotation_speed : float
	#@export var move_speed : float
	#@export var temp_visualizer : Node3D #to be used in dev time to check where the player is clicking
	#
	#@export_category("Cam Stuff")
	#@export var cam : Camera3D
	#@export var environment_cam : PhantomCamera3D
	#@export var fp_cam : PhantomCamera3D
	#@export var fp_rotation_speed : float
	#@export var rotation_target : Node3D
	#@export var digi_manager : Node3D
	#var timer : float
	#
	#@export_category("State Machines")
	#enum Move_State{FIRST_PERSON,POINT_AND_CLICK, MOVE_NULL}
	#@export var move_state : Move_State = Move_State.POINT_AND_CLICK
	#var from_fp : bool
	#enum FP_State{FP_IDLE, FP_WALK, FP_DIGI, FP_NULL}
	#@export var fp_state : FP_State = FP_State.FP_IDLE
	#enum PC_State{PC_IDLE, PC_WALK, PC_NULL}
	#@export var pc_state : PC_State = PC_State.PC_IDLE
	#var trigger_click_movement : bool
	#
	#func _ready():
		#_set_move_state(Move_State.POINT_AND_CLICK)
	#
	#func _process(delta):
		#match(move_state):
			#Move_State.POINT_AND_CLICK:
				##region Setup PC Camera
				#digi_manager.fp_cam_set = false
				#fp_cam.priority = 0
				#environment_cam.priority = 100
				#cam.set_orthogonal(25,.05,4000)
				##endregion
				##enable nav agent
				#match(pc_state):
					#PC_State.PC_IDLE:
						#pass
					#PC_State.PC_WALK:
						#if (nav_agent.is_navigation_finished()):
							#return
						##go to idle state
						#else:
							#_move_to_target(delta,move_speed)
					#PC_State.PC_NULL:
						#pass
			#Move_State.FIRST_PERSON:
				##region FP Camera
				#timer += delta
				#if (timer >= (fp_cam.tween_duration -.1)):
					#digi_manager.fp_cam_set = true
				#fp_cam.priority = 100
				#environment_cam.priority = 0
				#cam.set_perspective(50,.05,4000)
				##endregion
				#match(fp_state):
					##FP_State.FP_IDLE:
						##from_fp = true
						##var input_dir := Input.get_vector("left", "right", "up", "down")
						##if (input_dir != Vector2.ZERO):
							##_set_fp_state(FP_State.FP_WALK)
					##FP_State.FP_WALK:
						##var input_dir := Input.get_vector("left", "right", "up", "down")
						##var direction := (cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
						##if direction:
							##velocity.x = direction.x * move_speed
							##velocity.z = direction.z * move_speed
						##else:
							##velocity.x = 0.0
							##velocity.z = 0.0
						##pass
					#FP_State.FP_DIGI:
						#pass
					#FP_State.FP_NULL:
						#pass
		#move_and_slide()
	#
	##region Set States
	#func _set_move_state(next_move_state:int):
		#var prev_move_state := move_state
		#move_state = next_move_state
		#
		##check last state
		#match(prev_move_state):
			#Move_State.POINT_AND_CLICK:
				#_set_pc_state(PC_State.PC_NULL)
				#from_fp = false
			#Move_State.FIRST_PERSON:
				#_set_fp_state(FP_State.FP_NULL)
				#from_fp = true
	#
		##check upcoming state
		#match(next_move_state):
			#Move_State.POINT_AND_CLICK:
				#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
				#_set_pc_state(PC_State.PC_IDLE)
			#Move_State.FIRST_PERSON:
				#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				#_set_fp_state(FP_State.FP_DIGI)
	#
	#func _set_pc_state(next_pc_state:int):
		#var prev_pc_state := pc_state
		#pc_state = next_pc_state
		#
		##check prev state
		#match(prev_pc_state):
			#pass
			#
		##check next state
		#match(next_pc_state):
			#pass
	#
	#func _set_fp_state(next_fp_state:int):
		#var prev_fp_state := fp_state
		#fp_state = next_fp_state
		#
		##check prev state		
		#match(prev_fp_state):
			#pass
	#
		##check upcoming state
		#match(next_fp_state):
			#FP_State.FP_DIGI:
				#fp_cam.look_at_damping = true #floaty camera movement
				#digi_manager.toggle_digi = true #trigger digi behavior in digicam script
			#FP_State.FP_IDLE:
				#fp_cam.look_at_damping = false #no floaty movement
				#digi_manager.toggle_digi = false #digi disabled
	##endregion
	#
	#func _move_to_target(delta,speed): #setting point and click movement parameters
		#var target_position = nav_agent.get_next_path_position()
		#var direction = global_position.direction_to(target_position)
		##region Rotate To Look At Target
		#var target2D : Vector2 = Vector2(target_position.x, target_position.z)
		#var player2D : Vector2 = Vector2(global_position.x, global_position.z)
		#var face_direction = -(target2D - player2D)
		#rotation.y = lerp_angle(rotation.y, atan2(face_direction.x, face_direction.y), delta * rotation_speed)
	##endregion
		#velocity = direction * speed
	#
	#func _toggle_move(event):
		##region Toggle PC & FP
		#if (event.is_action_pressed("enter")): #this is where we toggle from fp view and pc view
			##toggle between point and click and first person
			#if (move_state == Move_State.POINT_AND_CLICK):
				#_set_move_state(Move_State.FIRST_PERSON)
			#elif(move_state == Move_State.FIRST_PERSON):
				#_set_move_state(Move_State.POINT_AND_CLICK)
			#timer = 0
		##endregion
	#
	#func _input(event):
		##region digicam view
		#if (event.is_action_pressed("digi_view")):
			#if (fp_state != FP_State.FP_DIGI):
				#if (move_state != Move_State.FIRST_PERSON):
					#_set_move_state(Move_State.FIRST_PERSON)
				#_set_fp_state(FP_State.FP_DIGI)
			#else:
				#if(from_fp):
					#_set_fp_state(FP_State.FP_IDLE)
				#else:
					#_set_move_state(Move_State.POINT_AND_CLICK)
				#pass
		##endregion
		#
		##region Checking for Point and Click Ability
		#if(Input.is_action_just_pressed("click") && (move_state == Move_State.POINT_AND_CLICK)):
			#var mouse_pos = get_viewport().get_mouse_position() #mouse position translated to WHERE in the viewport the mouse clicked
			#var ray_length = 1000 #length of raycast shot from mouse position
			#var from = cam.project_ray_origin(mouse_pos) #starting position of raycast
			#var to = from + cam.project_ray_normal(mouse_pos) * ray_length #target of raycast
			#var space = get_world_3d().direct_space_state #where raycast is being translated from
			#var ray_query = PhysicsRayQueryParameters3D.new() #new raycast
			#ray_query.from = from
			#ray_query.to = to
			#var result = space.intersect_ray(ray_query) #where the raycast intersects with an object
			#temp_visualizer.position = (result.position) #set visualizer for devs
			#nav_agent.set_target_position(result.position) #apply navigation
			##go to pc_walk 
			#_set_pc_state(PC_State.PC_WALK)
		##endregion
		#
		##region FP Mouse Movement
		#if (event is InputEventMouseMotion):
			#if (move_state == Move_State.FIRST_PERSON):
				#rotation_target.rotate_y(-event.relative.x * fp_rotation_speed)
				#rotation_target.rotate_x(-event.relative.y * fp_rotation_speed)
				#rotation_target.rotation.z = 0
				#rotation_target.rotation.x = clampf(rotation_target.rotation.x, -deg_to_rad(70), deg_to_rad(70))
				#rotation_target.rotation.y = clampf(rotation_target.rotation.y, -deg_to_rad(70), deg_to_rad(70))
				##rotation.y = rotation_target.rotation.y
			#elif (move_state == Move_State.POINT_AND_CLICK):
				##region Reset Rotation
				#rotation_target.rotation.x = 0
				#rotation_target.rotation.y = 0
				#rotation_target.rotation.z = 0
				##endregion
		##endregion
	#endregion
	pass



func _on_interaction_detector_area_entered(area):
	if(area.is_in_group("Interaction")):
		print("press E to interact")
