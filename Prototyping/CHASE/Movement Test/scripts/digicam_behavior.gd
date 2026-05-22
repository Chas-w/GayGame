extends Node3D

@export var camera_manager : Node
@export var main_UI : Control
@export var CRT_effect : ColorRect
@export var digi_move_speed : float
@export var rotation_target : Node3D
func _process(delta):
	
	if (camera_manager.toggle_digi): #if the player has triggered the digicam
		main_UI.visible = false #remove the game UI
		if (camera_manager.crt_ready): #after the camera transition
			CRT_effect.visible = true #use CRT effect
			_digi_mouse_control() #give camera mouse control
	else: 
		main_UI.visible = true #toggle UI on
		CRT_effect.visible = false #toggle CRT off
		#region Reset Rotation
		rotation_target.rotation.x = 0
		rotation_target.rotation.y = 0
		rotation_target.rotation.z = 0
		#endregion
		_release_cam_control() #take away mouse control

func _digi_mouse_control():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _release_cam_control():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	pass
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_target.rotate_y(-event.relative.x * digi_move_speed)
		rotation_target.rotate_x(-event.relative.y * digi_move_speed)
		rotation_target.rotation.z = 0
		rotation_target.rotation.x = clampf(rotation_target.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		rotation_target.rotation.y = clampf(rotation_target.rotation.y, -deg_to_rad(70), deg_to_rad(70))
