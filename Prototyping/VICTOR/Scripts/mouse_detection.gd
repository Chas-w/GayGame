extends Camera3D

@export_category("Attributes")
@export var detection_distance : float = 1000

var is_over_ball : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var result = get_intersect_result()
	if result.is_empty():
		is_over_ball = false
	else:
		if result.collider.name == "CueBall":
			is_over_ball = true
		else:
			is_over_ball = false

func get_intersect_result() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position() #mouse position translated to WHERE in the viewport the mouse clicked
	var ray_length = detection_distance #length of raycast shot from mouse position
	var from = project_ray_origin(mouse_pos) #starting position of raycast
	var to = from + project_ray_normal(mouse_pos) * ray_length #target of raycast
	var space = get_world_3d().direct_space_state #where raycast is being translated from
	var ray_query = PhysicsRayQueryParameters3D.new() #new raycast
	#ray_query.collision_mask = collision_mask
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query) #where the raycast intersects with an object
	return result
