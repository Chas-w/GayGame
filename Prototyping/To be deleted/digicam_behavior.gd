extends Node3D

var pic_count = 1 #keeps track of how many photos taken
var UI : CanvasLayer
@export var main_UI : Control
@export var CRT_effect : ColorRect
@export var digi_move_speed : float
@export var rotation_target : Node3D

var in_digi_view : bool
var fp_cam_set : bool
var toggle_digi : bool
func _ready():
	for game_obj in get_tree().get_nodes_in_group("UI"): #assign database
		UI = game_obj
	#region Setup Photo Files
	var dir = DirAccess.open("res://") #access directory
	dir.make_dir("photos") #create folder in directory
	dir = DirAccess.open("res://photos") #access updated directory
	for i in dir.get_files():
		pic_count += 1 #update pic count based on exisitng files
	#endregion

	main_UI = UI.get_child(0)

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
		if (fp_cam_set): #after the camera transition
			CRT_effect.visible = true #use CRT effect
			in_digi_view = true
	else: 
		main_UI.visible = true #toggle UI on
		CRT_effect.visible = false #toggle CRT off
		in_digi_view = false
	#endregion

func _input(event):
	if(event.is_action_pressed("click") && in_digi_view):
		_take_pic()
