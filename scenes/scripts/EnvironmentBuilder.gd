extends Node2D


const LEARNER_PATHS = {
	"ADP": "res://scenes/scripts/rl/learners/AdaptiveDynamicProgramming.gd",
	"MCES": "res://scenes/scripts/rl/learners/MonteCarloES.gd",
	"QLearning": "res://scenes/scripts/rl/learners/QLearning.gd",
	"Sarsa": "res://scenes/scripts/rl/learners/Sarsa.gd"
}
const PROPERTIES = {
	"Base reward": {"component": "rewarder", "property": "base_reward"},
	"Win reward": {"component": "rewarder", "property": "win_reward"},
	"Lose reward": {"component": "rewarder", "property": "lose_reward"},
	"Shift chance": {"component": "action_results", "property": "chance"}
}
const LEARNER_PROPERTIES = {
	"Gamma": "gamma",
	"Starting epsilon": "starting_epsilon",
	"Starting alpha": "starting_alpha",
	"Eps to converge": "episodes_to_zero"
}


var selected_tile = null
var can_build = false
var has_focus = false

var gamma
var starting_epsilon
var starting_alpha
var episodes_to_zero

@export var learner_name = "QLearning"

@onready var play_button = $"../Play"
@onready var environment: RLEnvironment = get_parent()
@onready var tile_buttons = [$Blocks/EmptyTile, $Blocks/WallTile, $Objects/WinTile, $Objects/LoseTile]
@onready var learner_buttons = [$Algorithms/VBoxContainer/ADP, $Algorithms/VBoxContainer/MCES, $Algorithms/VBoxContainer/Sarsa, $Algorithms/VBoxContainer/QLearning]
@onready var property_sliders = [$Rewards/BaseReward, $Rewards/WinReward, $Rewards/LoseReward, $Environment/ShiftChance]
@onready var learner_property_sliders = [$Values/Gamma, $Values/StartingEpsilon, $Values/StartingAlpha, $Values/EpisodesToZero]


func _ready():
	play_button.button_pressed = not environment.running
	
	for tile_button in tile_buttons:
		tile_button.connect("select", select_tile)
	
	for learner_button in learner_buttons:
		if learner_button.selection == learner_name:
			learner_button._pressed()
		learner_button.connect("select", select_learner)
	
	for property_slider in property_sliders:
		update_property(property_slider.property, property_slider.value)
		property_slider.connect("update_property", update_property)
	
	for learner_property_slider in learner_property_sliders:
		update_learner_property(learner_property_slider.property, learner_property_slider.value)
		learner_property_slider.connect("update_property", update_learner_property)

 
func _input(event):
	if Input.is_action_just_pressed("click"):
		if can_build and has_focus and selected_tile != null:
			environment.place_tile(selected_tile, Vector2i(get_viewport().get_mouse_position() / environment.CELL_SIZE))


func get_learner():
	var learner = load(LEARNER_PATHS[learner_name]).new()
	
	for p in ["gamma", "starting_epsilon", "starting_alpha", "episodes_to_zero"]:
		if learner.get(p) != null:
			learner.set(p, get(p))
	
	return learner


func select_learner(learner):
	for learner_button in learner_buttons:
		learner_button.deselect()
	
	learner_name = learner


func select_tile(tile_info):
	for tile_button in tile_buttons:
		tile_button.deselect()
	
	selected_tile = tile_info


func update_property(name, value):
	environment.get(PROPERTIES[name]["component"]).set(PROPERTIES[name]["property"], value)


func update_learner_property(name, value):
	set(LEARNER_PROPERTIES[name], value)


func focus_building():
	has_focus = true


func unfocus_building():
	has_focus = false
