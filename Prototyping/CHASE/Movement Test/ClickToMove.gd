extends CharacterBody3D
#https://youtu.be/KT06pv06Q1U?si=Oyfxr4sBKFvDll4p
@export var nav_agent : NavigationAgent3D
@export var cam : Camera3D
@export var move_speed : float
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(nav_agent.is_navigation_finished()):
		return
	else:
		_move_to_target(delta,move_speed)

func _move_to_target(delta,speed):
	var target_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	
	velocity = direction * speed
	move_and_slide()


func _input(event):
	if(Input.is_action_just_pressed("click")):
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 1000
		var from = cam.project_ray_origin(mouse_pos)
		var to = from + cam.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		var result = space.intersect_ray(ray_query)		
		nav_agent.set_target_position(result.position)
