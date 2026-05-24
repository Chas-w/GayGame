extends Node3D

var pic_count = 1 #keeps track of how many photos taken
@export var main_UI : Control
@export var CRT_effect : ColorRect
@export var digi_move_speed : float
@export var rotation_target : Node3D

var in_digi_view : bool
var crt_ready : bool
var toggle_digi : bool
func _ready():
	#region Setup Photo Files
	var dir = DirAccess.open("res://") #access directory
	dir.make_dir("photos") #create folder in directory
	dir = DirAccess.open("res://photos") #access updated directory
	for i in dir.get_files():
		pic_count += 1 #update pic count based on exisitng files
	#endregion

func _take_pic():
	await RenderingServer.frame_post_draw
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image() #access image texture of the viewport
	img.save_png("res://photos/pic_"+str(pic_count)+".png") #save the image to directory
	pic_count += 1 #increase pic count for future naming conventions

func _process(delta):

	#region Digi Setup / Breakdown
	if (toggle_digi): #if the player has triggered the digicam
		main_UI.visible = false #remove the game UI
		if (crt_ready): #after the camera transition
			CRT_effect.visible = true #use CRT effect
			_digi_mouse_control() #give camera mouse control
	else: 
		main_UI.visible = true #toggle UI on
		CRT_effect.visible = false #toggle CRT off
		_release_cam_control() #take away mouse control
	#endregion


func _digi_mouse_control():
	in_digi_view = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _release_cam_control():
	in_digi_view = false
	#region Reset Rotation
	rotation_target.rotation.x = 0
	rotation_target.rotation.y = 0
	rotation_target.rotation.z = 0
	#endregion
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _input(event):
	#region Capture Mouse Movement
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_target.rotate_y(-event.relative.x * digi_move_speed)
		rotation_target.rotate_x(-event.relative.y * digi_move_speed)
		rotation_target.rotation.z = 0
		rotation_target.rotation.x = clampf(rotation_target.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		rotation_target.rotation.y = clampf(rotation_target.rotation.y, -deg_to_rad(70), deg_to_rad(70))
	#endregion
	if (in_digi_view && event.is_action_pressed("click")):
		_take_pic()
