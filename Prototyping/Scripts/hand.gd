extends RigidBody2D

var mouse_down := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if(event.is_pressed()) :
			mouse_down = true
		if(event.is_released()) :
			mouse_down = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(mouse_down)
	pass

func _physics_process(delta: float) -> void:
	if mouse_down:
		apply_force((get_local_mouse_position() - global_position) * 5)
