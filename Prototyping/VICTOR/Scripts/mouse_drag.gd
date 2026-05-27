extends Node3D

@export var temp_visualizer : Node3D
@export var pong_ball : RigidBody3D
@export var cam : Camera3D
@export var correction_force : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position() #mouse position translated to WHERE in the viewport the mouse clicked
	var ray_length = 1000 #length of raycast shot from mouse position
	var from = cam.project_ray_origin(mouse_pos) #starting position of raycast
	var to = from + cam.project_ray_normal(mouse_pos) * ray_length #target of raycast
	var space = get_world_3d().direct_space_state #where raycast is being translated from
	var ray_query = PhysicsRayQueryParameters3D.new() #new raycast
	#ray_query.collision_mask
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query) #where the raycast intersects with an object
	temp_visualizer.position = (result.position) #set visualizer for devs

func _physics_process(delta: float) -> void:
	var force_direction = temp_visualizer.position - pong_ball.position
	pong_ball.apply_force(force_direction * correction_force)
