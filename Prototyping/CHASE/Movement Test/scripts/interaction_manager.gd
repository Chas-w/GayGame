extends Node3D

@export_category("Setup")
@export var ID : String
@export var target_name : String
@export var scene_group : String
@export var has_dialogue : bool

@export_category("Dialogue")
@export var dia_source : JSON
@export var current_key : String

func _process(delta):
	pass

func _enter_interaction():
	pass

func _exit_interaction(): 
	pass

func _process_interaction():
	pass
