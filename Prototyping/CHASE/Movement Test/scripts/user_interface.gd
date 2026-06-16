extends CanvasLayer

@export_category("Setup")
@export var main_ui : Control
@export var dialogue_ui : Control
@export var digicam_ui : Control
@export var char_creator_ui : Control
@export var bracelet_button : Button
@export var bracelet_anim :AnimationPlayer
var hover_bracelet


@export_category("States")
enum UI_State{OVERWORLD, DIALOGUE, DIGICAM, MINIGAME}
@export var ui_state : UI_State = UI_State.OVERWORLD

@export_category("Digicam Vars")
@export var page : GridContainer
@export var pictures : Array[TextureButton]
var picture_paths : Array[String]
@export var focus_photo : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_ui_state(UI_State.OVERWORLD)

func _process(delta):
	if (bracelet_button.is_hovered() && !hover_bracelet):
		hover_bracelet = true
		bracelet_anim.play("hover_bracelet")
	
	elif(!bracelet_button.is_hovered() && hover_bracelet):
		bracelet_anim.play("return_bracelet")
		hover_bracelet = false

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
func _focus_photo(photo_path : String):
	pass

#func _take_photo():
	#var img = get_viewport().get_texture().get_image()
	#var tex = ImageTexture.new()
	#tex.create_from_image(img)
	#focus_photo.texture = tex
	#print(img)
