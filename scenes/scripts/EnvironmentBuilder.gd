extends Node2D


var selected_tile = null
var can_build = false
var has_focus = false


@onready var play_button = $"../Play"
@onready var environment: RLEnvironment = get_parent()
@onready var tile_buttons = [$Blocks/EmptyTile, $Blocks/WallTile, $Objects/WinTile, $Objects/LoseTile]


func _ready():
	play_button.button_pressed = not environment.running
	
	for tile_button in tile_buttons:
		tile_button.connect("select", select_tile)

 
func _input(event):
	if Input.is_action_just_pressed("click"):
		if can_build and has_focus and selected_tile != null:
			environment.place_tile(selected_tile, Vector2i(get_viewport().get_mouse_position() / environment.CELL_SIZE))


func select_tile(tile_info):
	for tile_button in tile_buttons:
		tile_button.deselect()
	
	selected_tile = tile_info


func focus_building():
	has_focus = true


func unfocus_building():
	has_focus = false
