extends Camera3D

@export_flags_3d_physics var layers_3d_physics

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.is_pressed() and event.:
		#pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click") :
		print(_shoot_ray())

func _shoot_ray() -> Vector3:
	var mouse_position : Vector3
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = layers_3d_physics
	var raycast_result = space.intersect_ray(ray_query)
	return raycast_result["position"]
