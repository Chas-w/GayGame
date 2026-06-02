extends CharacterBody3D
#https://youtu.be/KT06pv06Q1U?si=Oyfxr4sBKFvDll4
@export_category("Movement Variables")
@export var nav_agent : NavigationAgent3D
@export var rotation_speed : float
@export var move_speed : float
@export var temp_visualizer : Node3D #to be used in dev time to check where the player is clicking
var moving : bool 

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

@export_category("Interaction Variables")
@export var can_interact : bool 
@export var dialogue_interaction : bool
var interaction_source : Node3D
	

func _ready():
	_set_move_state(Move_State.POINT_AND_CLICK) #setup for point and click

func _process(delta):
	match(move_state):
		Move_State.POINT_AND_CLICK:
			match(pc_state):
				PC_State.PC_WALK:
					#region Applying Point and Click Movement
					if (!digi_manager.toggle_digi): #as long as the camera isn't in digicam mode
						if(nav_agent.is_navigation_finished() ): #if navigation is finished do NOTHING (breaks the movement loop)
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
			if (interaction_source.can_exit && Input.is_action_just_pressed("exit")):
				interaction_source.trigger_exit = true
				_set_move_state(Move_State.POINT_AND_CLICK)
			if (interaction_source.can_move_scene && Input.is_action_just_pressed("enter")):
				interaction_source._next_scene()
			pass
		Move_State.INSPECTING:
			pass
		Move_State.IN_MENU:
			pass

func _move_to_target(delta,speed): #setting point and click movement parameters
	var target_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	#region Rotate To Look At Target
	if (velocity != Vector3.ZERO):
		var target2D : Vector2 = Vector2(target_position.x, target_position.z)
		var player2D : Vector2 = Vector2(global_position.x, global_position.z)
		var face_direction = -(target2D - player2D)
		rotation.y = lerp_angle(rotation.y, atan2(face_direction.x, face_direction.y), delta * rotation_speed)
		moving = true
	else:
		moving = false
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
		Move_State.CHATTING:
			cam.set_orthogonal(50,.05,4000)
			environment_cam.priority = 100
			interaction_source.get_child(1).priority = 0
		pass
	#check upcoming state
	match(next_move_state):
		Move_State.POINT_AND_CLICK:
			#region Setup PC Camera
			digi_manager.fp_cam_set = false
			fp_cam.priority = 0
			environment_cam.priority = 100
			cam.set_orthogonal(40,.05,4000)
			#endregion
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			_set_PC_state(PC_State.PC_WALK)
		Move_State.DIGICAM:
			timer = 0
			nav_agent.set_target_position(position) #stop the movement, reset the target position
			temp_visualizer.position = position
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			_set_PC_state(PC_State.PC_NULL)
		Move_State.CHATTING:
			cam.set_perspective(45,.05,4000)
			interaction_source.get_child(1).priority = 100
			environment_cam.priority = 0
			interaction_source._enter_interaction()
			pass
		Move_State.INSPECTING:
			pass
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
	#region digicam input
	
	if(Input.is_action_just_pressed("digi_view") && move_state != Move_State.CHATTING && move_state != Move_State.INSPECTING):
		digi_manager.toggle_digi = !digi_manager.toggle_digi
		if(digi_manager.toggle_digi):
			_set_move_state(Move_State.DIGICAM)
		else:
			_set_move_state(Move_State.POINT_AND_CLICK)
	#endregion

	#region Checking for Point and Click Ability
	if(Input.is_action_just_pressed("click") && !digi_manager.toggle_digi && move_state != Move_State.CHATTING && move_state != Move_State.INSPECTING):
		var mouse_pos = get_viewport().get_mouse_position() #mouse position in world space
		var ray_length = 1000 #length of raycast shot from mouse position
		var from = cam.project_ray_origin(mouse_pos) #starting position of raycast
		var to = from + cam.project_ray_normal(mouse_pos) * ray_length #target of raycast
		var space = get_world_3d().direct_space_state #where raycast is being translated from
		var ray_query = PhysicsRayQueryParameters3D.new() #new raycast
		ray_query.from = from
		ray_query.to = to
		var result = space.intersect_ray(ray_query) #where the raycast intersects with an object
		if(result != { }): #ensuring that this is a clickable space
			var clicked_node = result.collider
			if (clicked_node.is_in_group("Ground")): #ensuring that this is where we want the player to be targeting
				temp_visualizer.position = (result.position) #set visualizer for devs
				nav_agent.set_target_position(result.position) #apply navigation
	#region turn in place
	if (Input.is_action_just_pressed("rotate") && move_state == Move_State.POINT_AND_CLICK && !moving):
		rotation.y += 1
	#endregion
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

	#region interact input
	if(event.is_action_pressed("interact") && can_interact && move_state != Move_State.DIGICAM):
		if(!interaction_source.entered):
			if (interaction_source.is_dialogue):
				_set_move_state(Move_State.CHATTING)
			else:
				_set_move_state(Move_State.INSPECTING)
		elif(interaction_source.entered):
			interaction_source._progress_interaction()
	#endregion

func _on_interaction_detector_area_entered(area):
	if(area.is_in_group("Interaction")):
		can_interact = true
		interaction_source = area.get_parent()
func _on_interaction_detector_area_exited(area):
	if(area.is_in_group("Interaction")):
		can_interact = false
	
