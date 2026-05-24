extends MeshInstance3D

var is_complete : bool
var collider : CollisionShape3D
var mesh_var : MeshInstance3D
var manager : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ball_entered(ball: Node3D) -> void:
	if !is_complete and ball.name == "PongBall":
		is_complete = true
		if manager != null:
			manager.player_cups.erase(self)
		else:
			print("MANAGER IS NULL")
		queue_free()
