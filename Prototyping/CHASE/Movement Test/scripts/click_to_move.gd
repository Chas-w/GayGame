extends CharacterBody3D
#https://youtu.be/KT06pv06Q1U?si=Oyfxr4sBKFvDll4p
@export var nav_agent : NavigationAgent3D
@export var cam : Camera3D
@export var move_speed : float
@export var temp_visualizer : Node3D #to be used in dev time to check where the player is clicking
@export var camera_manager : Node

func _process(delta):
#region Applying Point and Click Movement
	if (!camera_manager.toggle_digi): #as long as the camera isn't in digicam mode
		if(nav_agent.is_navigation_finished()): #if navigation is finished do NOTHING (breaks the movement loop)
			return
		else:
			_move_to_target(delta,move_speed) #otherwise, continuously move towards the target position at preset speed (move_speed)
	else:
		nav_agent.set_target_position(position) #stop the movement, reset the target position
		temp_visualizer.position = position
#endregion

func _move_to_target(delta,speed): #setting point and click movement parameters
	var target_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	move_and_slide()


func _input(event):
#region Checking for Point and Click Ability
	if(Input.is_action_just_pressed("click") && !camera_manager.toggle_digi):
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
