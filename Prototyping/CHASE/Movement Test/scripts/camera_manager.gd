extends Node
@export var cam : Camera3D
@export var environment_cam : PhantomCamera3D
@export var digi_cam : PhantomCamera3D
var toggle_digi : bool 
var timer : float
var crt_ready : bool 

func _process(delta):
	if (Input.is_action_just_pressed("enter")): #this is where we toggle from digi view and main view
		toggle_digi = !toggle_digi 
		timer = 0
	if(!toggle_digi): #digicam off
		crt_ready = false
		digi_cam.priority = 0
		environment_cam.priority = 100
		cam.set_orthogonal(25,.05,4000)
	if(toggle_digi): #digicam on
		timer += delta
		if (timer >= (digi_cam.tween_duration -.1)):
			crt_ready = true
		digi_cam.priority = 100
		environment_cam.priority = 0
		cam.set_perspective(50,.05,4000)
