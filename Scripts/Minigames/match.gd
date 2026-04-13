extends Sprite3D

@export var fire_sprite : Sprite3D

@export var lit_time : float
var lit_timer : float

@export var max_tries : int
var times_lit : int

var is_lit : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_lit:
		lit_timer += delta
	if lit_timer > lit_time:
		lit_timer = 0
		toggle_match(false)
	if Input.is_action_just_pressed("pose") and !is_lit and times_lit < max_tries:
		light_match()
	if Input.is_key_pressed(KEY_R):
		start_game()

#Randomize angle, start match inactive
func start_game() -> void:
	var random_angle = randi_range(0, 360)
	fire_sprite.rotation_degrees = Vector3(0, 0, random_angle)
	times_lit = 0
	toggle_match(false)

#Light match to see angle
func light_match() -> void:
	toggle_match(true)
	times_lit += 1

#Turn match and appropriate booleans off
func toggle_match(toggle : bool) -> void:
	fire_sprite.visible = toggle
	is_lit = toggle
