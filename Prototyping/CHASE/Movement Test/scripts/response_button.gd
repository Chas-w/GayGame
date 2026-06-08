extends Button
@export var dialogue_manager : Node3D

@export var connected_responses : Array[String]
#used to delete responses on a similar path

func _process(delta):
	if (button_pressed):
		dialogue_manager._player_response(self)
