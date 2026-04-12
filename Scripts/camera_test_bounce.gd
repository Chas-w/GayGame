extends Camera3D

@export var amplitude: float = 2.0   
@export var frequency: float = 1.0   

var origin_x: float

func _ready() -> void:
	origin_x = position.x

func _process(delta: float) -> void:
	position.x = origin_x + sin(Time.get_ticks_msec() / 1000.0 * frequency * TAU) * amplitude
