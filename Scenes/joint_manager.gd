extends Sprite3D

@export var joint_array : Array[Node3D]
@export var timer_display : Label
@export var time : float
var timer : float
var current_joint : int = joint_array.size() - 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_joint = joint_array.size() - 1
	change_joint(current_joint)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_display.text = str(time - timer)
	if current_joint > 0 :
		timer += delta
		if timer > time :
			timer = 0
			change_joint(current_joint - 1)
	
	#if Input.is_action_just_pressed("right"):
		#change_joint(current_joint + 1)
	#if Input.is_action_just_pressed("left"):
		#change_joint(current_joint - 1)

func change_joint(new_joint : int) :
	if new_joint > joint_array.size() - 1:
		new_joint = 0
	elif new_joint < 0:
		#new_joint = joint_array.size() - 1
		return
	
	joint_array[current_joint].toggle_limb(false)
	joint_array[new_joint].toggle_limb(true)
	
	current_joint = new_joint
	pass
