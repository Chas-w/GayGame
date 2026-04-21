extends Label
@export var right_key : Label
@export var left_key : Label
@export var above_key : Label
@export var below_key : Label

@export var enter : bool
@export var space : bool 

var hover_position 



func _ready():
	hover_position = Vector2(global_position.x + 6, global_position.y + 12)	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
