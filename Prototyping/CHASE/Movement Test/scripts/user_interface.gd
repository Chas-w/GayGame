extends CanvasLayer

@export_category("Setup")
@export var main_ui : Control
@export var dialogue_ui : Control
@export var digicam_ui : Control

@export_category("States")
enum UI_State{OVERWORLD, DIALOGUE, DIGICAM, MINIGAME}
@export var ui_state : UI_State = UI_State.OVERWORLD

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_ui_state(UI_State.OVERWORLD)
	pass # Replace with function body.

func _process(delta):
	pass

func _set_ui_state(next_state:int):
	var prev_ui_state := ui_state
	ui_state = next_state
		
	#check last state
	match(prev_ui_state):
		UI_State.OVERWORLD:
			main_ui.visible = false
		UI_State.DIALOGUE:
			dialogue_ui.visible = false
		UI_State.DIGICAM:
			digicam_ui.visible = false
		pass	
	#setup next state
	match(next_state):
		UI_State.OVERWORLD:
			main_ui.visible = true
		UI_State.DIALOGUE:
			dialogue_ui.visible = true
		UI_State.DIGICAM:
			digicam_ui.visible = true
		pass

func _setup_digi_menu():
	pass

func _add_to_photobook(photo_path : String):
	pass
	
func _focus_photo(photo_path : String):
	pass
