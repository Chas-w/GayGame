extends CharacterBody3D

#Attributes
@export_range(0, 5) var speed : float
@export_range(0, 0.015) var sensitivity : float
@export var viewport_container: SubViewportContainer
@export var player_body : Node3D

#References
@onready var pivot := $CameraPivot
@onready var camera := $CameraPivot/Camera3D
#@onready var player_body := $CameraPivot/Camera3D/PlayerBody
@onready var camera_cast := $CameraPivot/Camera3D/RayCast3D

#Variables
var is_posing : bool = false

func _ready() -> void:
	viewport_container.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !is_posing:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion and !is_posing:
		pivot.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func _process(delta: float) -> void:
	if camera_cast.get_collider():
		viewport_container.visible = true
	elif !is_posing:
		viewport_container.visible = false
	if Input.is_action_just_pressed("pose"):
		_toggle_posing()

func _physics_process(delta: float) -> void:
	if !is_posing:
		_handle_movement()
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()

func _toggle_posing():
	is_posing = !is_posing
	player_body.toggle_posing(is_posing)
	viewport_container.visible = is_posing
	if is_posing:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _handle_movement():
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
