extends Node2D


@onready var play_button = $Play
@onready var environment: RLEnvironment = get_parent()


var selected_tile = null
var can_build = false
var has_focus = false


func _ready():
	play_button.button_pressed = not environment.running
	
	selected_tile = {"layer": environment.ENVIRONMENT_LAYER,
						"source_id": environment.ENVIRONMENT_ID,
						"atlas_coords": environment.EMPTY_TILE}

 
func _input(event):
	if Input.is_action_just_pressed("click"):
		if can_build and has_focus and selected_tile != null:
			environment.place_tile(selected_tile, Vector2i(get_viewport().get_mouse_position() / environment.CELL_SIZE))


func focus_building():
	has_focus = true


func unfocus_building():
	has_focus = false
