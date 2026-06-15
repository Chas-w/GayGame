extends Node3D
#will eventually use a JSON to sift through what is applicable
#region Variables
@export_category("Setup")
@export var cam : Camera3D
var UI
var next_button : Button
var prev_button : Button

@export_category("Export Player")
@export var export_char = preload("res://Prototyping/CHASE/Movement Test/scenes/player_mesh.tscn")
# ^ prob won't use this prob will grab it directly from the player
@export var editable_char : Node3D
var player
@export_category("Heads")
@export var default_head : MeshInstance3D
@export var head_options : Array[MeshInstance3D]
@export_category("Torsos")
@export var default_torso : MeshInstance3D
@export var torso_options : Array[MeshInstance3D]
@export_category("Arms")
@export var default_arms : MeshInstance3D
@export var arm_options : Array[MeshInstance3D]
@export_category("Hands")
@export var default_hands : MeshInstance3D
@export var hand_options : Array[MeshInstance3D]
@export_category("Legs")
@export var default_legs : MeshInstance3D
@export var leg_options : Array[MeshInstance3D]
@export_category("Shoes")
@export var shoe_options : Array[MeshInstance3D]
@export_category("Hats")
@export var hat_options : Array[MeshInstance3D]

#BUTTON STUFF
var buffer_max = .5
var buffer
var press : bool

#ARRAY STUFF
enum Body {HEAD, TORSO, ARMS, HANDS, LEGS, SHOES}
@export var modify : Body = Body.HEAD

var place_in_array : int #will be reset any time we switch body part categories
var current_head
var current_torso
var current_arms
var current_hands
var current_legs
var current_shoes
#endregion


func _ready():
	#hide the player instance
	buffer = buffer_max
	for game_obj in get_tree().get_nodes_in_group("UI"): #assign database
		UI = game_obj
	next_button = UI.get_child(3).get_child(0).get_child(0)
	prev_button = UI.get_child(3).get_child(0).get_child(1)
	_set_modify_body(Body.HEAD)

func _process(delta):
#region Button Stuff
	if (press):
		if (buffer > 0):
			buffer -= delta
		if (buffer <= 0):
			press = false


	match(modify):
		Body.HEAD:
			for i in head_options.size():
				if (i == place_in_array):
					head_options[i].visible = true
					current_head = head_options[i]
				else:
					head_options[i].visible = false
			if (next_button.button_pressed && !press):
				press = true
				buffer = buffer_max
				if (place_in_array < head_options.size() - 1):
					place_in_array += 1
					print("[CURRENT HEAD: " + head_options[place_in_array].name + "]")
				else:
					place_in_array = 0
					print("[CURRENT HEAD: " + head_options[place_in_array].name + "]")
			if (prev_button.button_pressed && !press):
				press = true
				buffer = buffer_max
				if (place_in_array > 0):
					place_in_array -= 1
					print("[CURRENT HEAD: " + head_options[place_in_array].name + "]")
				else:
					place_in_array = head_options.size() - 1
					print("[CURRENT HEAD: " + head_options[place_in_array].name + "]")


			pass
#endregion


		
func _set_modify_body(next_modify):
	var prev_body := modify
	modify = next_modify

	match(prev_body):
		#set the values for export mesh
		pass
	
	match(modify):
		Body.HEAD:
			for i in head_options.size():
				if (head_options[i].visible):
					print("[CURRENT HEAD: " + head_options[i].name + "]")
					current_head = head_options[i]
					place_in_array = i
#func _input(event):
	#if(Input.is_action_just_pressed("click")):
		#var mouse_pos = get_viewport().get_mouse_position() #mouse position in world space
		#
		#var ray_length = 1000 #length of raycast shot from mouse position
		#var from = cam.project_ray_origin(mouse_pos) #starting position of raycast
		#var to = from + cam.project_ray_normal(mouse_pos) * ray_length #target of raycast
		#var space = get_world_3d().direct_space_state #where raycast is being translated from
		#var ray_query = PhysicsRayQueryParameters3D.new() #new raycast
		#ray_query.from = from
		#ray_query.to = to
		#var result = space.intersect_ray(ray_query) #where the raycast intersects with an object
		#if(result != { }): #ensuring that this is a clickable space
			#print(result)
			#var clicked_node = result.collider
