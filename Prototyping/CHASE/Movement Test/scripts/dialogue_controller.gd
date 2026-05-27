extends Node3D

func _start_dialogue(dialogue : Resource):
	DialogueManager.show_dialogue_balloon(dialogue, "start")
