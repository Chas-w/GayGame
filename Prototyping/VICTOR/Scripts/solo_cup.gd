extends MeshInstance3D

var is_complete : bool
var collider : CollisionShape3D
var mesh_var : MeshInstance3D
var manager : Node3D

var complete_position : Vector3
var move_speed : float = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	complete_position = position + Vector3(0, 3, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_complete:
		if position != complete_position:
			position = position.move_toward(complete_position, delta * move_speed)
		else:
			queue_free()
	

func _on_ball_entered(ball: Node3D) -> void:
	if !is_complete and ball.name == "PongBall":
		is_complete = true
		if manager != null:
			#manager.player_cups.erase(self)
			manager.destroy_player_cup(self)
		else:
			print("MANAGER IS NULL")


func _on_ball_entered_top(ball: Node3D) -> void:
	ball.toggle_bounce(false)
