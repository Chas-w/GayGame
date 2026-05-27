extends RigidBody3D

@export var bounce_material : PhysicsMaterial
@export var no_bounce_material : PhysicsMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func freeze_ball_at_point(freeze_position: Vector3, freeze_rotation: Vector3) -> void:
	freeze = true
	position = freeze_position
	rotation = freeze_rotation

func release_ball_at_point(release_position: Vector3, release_rotation: Vector3) -> void:
	position = release_position
	rotation = release_rotation
	freeze = false

func toggle_bounce(toggle: bool) -> void:
	if toggle:
		physics_material_override = bounce_material
	else:
		physics_material_override = no_bounce_material
