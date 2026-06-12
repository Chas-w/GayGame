extends Node3D
#will eventually use a JSON to sift through what is applicable
#region Variables
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
#endregion


func _ready():
	#hide the player instance
	
	pass
	
func _process(delta):
	pass
