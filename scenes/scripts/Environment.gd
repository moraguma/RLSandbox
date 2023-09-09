extends TileMap
class_name RLEnvironment

# --------------------------------------------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------------------------------------------

@export var action_list: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

# Tileset data -----------------------------------------------------------------
const CELL_SIZE = 64

const INVALID_TILE = Vector2i(-1, -1)

const ENVIRONMENT_LAYER = 1
const ENVIRONMENT_ID = 0
const EMPTY_TILE = Vector2i(0, 0)
const WALL_TILE = Vector2i(0, 1)

const OBJECT_LAYER = 0
const OBJECT_ID = 1
const WIN_TILE = Vector2i(1, 2)
const LOSE_TILE = Vector2i(1, 3)
const ACTION_TO_TILE = {
	Vector2i(0, -1): Vector2i(0, 0),
	Vector2i(1, 0): Vector2i(0, 1),
	Vector2i(0, 1): Vector2i(0, 3),
	Vector2i(-1, 0): Vector2i(0, 2),
	Vector2i(-1, 1): Vector2i(1, 0),
	Vector2i(1, 1): Vector2i(2, 0),
	Vector2i(-1, -1): Vector2i(1, 1),
	Vector2i(1, -1): Vector2i(2, 1)
}
const TILE_TO_ACTION = {
	Vector2i(0, 0): Vector2i(0, -1),
	Vector2i(0, 1): Vector2i(1, 0),
	Vector2i(0, 3): Vector2i(0, 1),
	Vector2i(0, 2): Vector2i(-1, 0),
	Vector2i(1, 0): Vector2i(-1, 1),
	Vector2i(2, 0): Vector2i(1, 1),
	Vector2i(1, 1): Vector2i(-1, -1),
	Vector2i(2, 1): Vector2i(1, -1)
}

const MAX_H = 14
const MAX_V = 7

# Agent data -------------------------------------------------------------------
const AGENT_SPRITE_DEFAULT_OFFSET = Vector2(0, -32)
const AGENT_SPRITE_LERP_WEIGHT = 0.5

# Rendering --------------------------------------------------------------------
const MIN_FRAMES_PER_ITERATION = 1
const MAX_FRAMES_PER_ITERATION = 60

# Visualization ----------------------------------------------------------------
const EPISODES_TO_AVERAGE = 20
const MAX_DATA_POINTS = 1000
const CHARS_PRE_GRAPH = 34

# --------------------------------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------------------------------

# Builder ----------------------------------------------------------------------
var running = false

# Environment ------------------------------------------------------------------
var graph = {}

var trial = [] # List of [s, a, r]
var episodes = 0
var max_steps = 50

# Components -------------------------------------------------------------------
var action_results: ActionResults = preload("res://scenes/scripts/env_components/action_results/SidewaysShift.gd").new()
var resetter: Resetter = preload("res://scenes/scripts/env_components/resetters/RandomResetter.gd").new()
var rewarder: Rewarder = preload("res://scenes/scripts/env_components/rewarders/FixedRewarder.gd").new()
var learner: Learner

# Rendering --------------------------------------------------------------------
@export var headless_episodes = 0
var frames_passed = 0

# Visualization ----------------------------------------------------------------

# Graph
var cummulative_reward = 0
var running_total_reward = 0
var running_episodes = 0
var g_function: Function = null
var averaged_function: Function = null

# --------------------------------------------------------------------------------------------------
# NODES
# --------------------------------------------------------------------------------------------------

@onready var agent_sprite = $Agent
@onready var simulation_speed = $SimulationSpeed
@onready var speed_slider = $Slider
@onready var environment_builder = $EnvironmentBuilder
@onready var play_button = $Play
@onready var value_function_holder = $ValueFunction
@onready var policy_holder = $Policy
@onready var instructions = $Instructions

# --------------------------------------------------------------------------------------------------
# BUILT-INS
# --------------------------------------------------------------------------------------------------

func _ready():
	stop()


func _process(delta):
	if running:
		agent_sprite.offset = lerp(agent_sprite.offset, AGENT_SPRITE_DEFAULT_OFFSET, AGENT_SPRITE_LERP_WEIGHT)
		
		frames_passed += 1
		if frames_passed >= MAX_FRAMES_PER_ITERATION - (MAX_FRAMES_PER_ITERATION - MIN_FRAMES_PER_ITERATION) * speed_slider.value:
			frames_passed = 0
			
			_iterate_algorithm()
	
	if Input.is_action_just_pressed("value_function"):
		value_function_holder.show()
	elif Input.is_action_just_released("value_function"):
		value_function_holder.hide()
	
	if Input.is_action_just_pressed("policy"):
		policy_holder.show()
	elif Input.is_action_just_released("policy"):
		policy_holder.hide()


# Calls function for the chosen RL algorithm
func _iterate_algorithm():
	environment_step()
	cummulative_reward += trial[-1][2]
	
	learner.rl_step(trial, is_terminal(trial[-1][0]), self)
	
	if is_terminal(trial[-1][0]):
		reset_episode()


# --------------------------------------------------------------------------------------------------
# BUILDER
# --------------------------------------------------------------------------------------------------
func toggle_start():
	if running:
		stop()
	else:
		var valid_map = false
		for tile in get_used_cells_by_id(ENVIRONMENT_LAYER, ENVIRONMENT_ID):
			if is_tile_playable(tile):
				valid_map = true
				break
		
		if len(action_list) > 0 and valid_map:
			start()
		else:
			play_button.set_pressed_no_signal(false)


func is_tile_playable(tile: Vector2i) -> bool:
	var env = get_cell_atlas_coords(ENVIRONMENT_LAYER, tile)
	var obj = get_cell_atlas_coords(OBJECT_LAYER, tile)
	return env != WALL_TILE and not obj in [WIN_TILE, LOSE_TILE]


func start():
	agent_sprite.show()
	
	running = true
	environment_builder.can_build = false
	
	randomize()
	
	learner = environment_builder.get_learner()
	build_graph()
	build_value_view()
	build_policy_view()
	reset_tilemap_policy()
	reset_values()
	
	while episodes < headless_episodes:
		_iterate_algorithm()
	
	instructions.visible_characters = 34
	instructions.show()
	
	environment_builder.hide()
	agent_sprite.show()
	simulation_speed.show()
	speed_slider.show()


func stop():
	play_button.set_pressed_no_signal(false)
	agent_sprite.hide()
	
	running = false
	environment_builder.can_build = true
	
	DataVisualizer.viewable = false
	
	reset_value_view()
	reset_policy_view()
	
	instructions.hide()
	environment_builder.show()
	simulation_speed.hide()
	speed_slider.hide()


func reset_values():
	episodes = 0
	trial = []
	
	g_function = null
	averaged_function = null 
	running_episodes = 0
	running_total_reward = 0


func place_tile(tile_info, coords: Vector2i):
	if tile_info["source_id"] == OBJECT_ID:
		assert(tile_info["layer"] == OBJECT_LAYER, "Object used in non object layer!")
		
		if get_cell_atlas_coords(ENVIRONMENT_LAYER, coords) == WALL_TILE:
			return
	elif tile_info["source_id"] == ENVIRONMENT_ID:
		assert(tile_info["layer"] == ENVIRONMENT_LAYER, "Environment used in non environment layer!")
		set_cell(OBJECT_LAYER, coords, -1)
	
	if coords[0] > 0 and coords[0] < MAX_H and coords[1] > 0 and coords[1] < MAX_V:
		set_cell(tile_info["layer"], coords, tile_info["source_id"], tile_info["atlas_coords"])

# --------------------------------------------------------------------------------------------------
# ENVIRONMENT
# --------------------------------------------------------------------------------------------------

# Builds the MDP that represents the problem
func build_graph():
	graph = {}
	
	var empty_tiles = get_used_cells_by_id(ENVIRONMENT_LAYER, ENVIRONMENT_ID, EMPTY_TILE)
	
	for tile in empty_tiles:
		var object = get_cell_atlas_coords(OBJECT_LAYER, tile)
		if object != WIN_TILE and object != LOSE_TILE:
			graph[tile] = {}
			
			for i in range(len(action_list)):
				graph[tile][action_list[i]] = action_results.get_result(self, tile, action_list[i])
				for j in range(len(graph[tile][action_list[i]])):
					graph[tile][action_list[i]][j][0] = get_movement_result(tile, graph[tile][action_list[i]][j][0])


func reset_tilemap_policy():
	var object_tiles = get_used_cells_by_id(OBJECT_LAYER, OBJECT_ID)
	
	for tile in object_tiles:
		if get_cell_atlas_coords(OBJECT_LAYER, tile) in TILE_TO_ACTION:
			set_cell(OBJECT_LAYER, tile, -1)


# Gets the resulting tile of a movement as a Vector2i
func get_movement_result(start, action):
	if get_cell_atlas_coords(ENVIRONMENT_LAYER, start + action) == WALL_TILE:
		return start
	return start + action


# Checks if this state is terminal
func is_terminal(state):
	return get_cell_atlas_coords(OBJECT_LAYER, state) in [WIN_TILE, LOSE_TILE] or len(trial) >= max_steps


# Takes a step in a trial according to its learner. If a trial isn't
# running, places the agent in a random position.
func environment_step():
	if len(trial) == 0:
		move_to(resetter.get_initial_tile(graph))
	else:
		var past_state = trial[-1][0]
		trial[-1][1] = learner.select_action(past_state, action_list, self)
		
		take_step(past_state, trial[-1][1])


# Takes a step considering the specified action and returns the result based on 
# the random resulting state
func take_step(state, action):
	set_cell(OBJECT_LAYER, state, OBJECT_ID, ACTION_TO_TILE[action])
	
	var r = randf()
	
	for result_probability in graph[state][action]:
		if r <= result_probability[1]:
			move_to(result_probability[0])
			return
		r -= result_probability[1]


# Moves agent to specified state and updates trial with new state and reward
func move_to(state):
	trial.append([state, null, rewarder.get_reward(self, state)])
	
	move_agent_to(Vector2(state) * CELL_SIZE)


func move_agent_to(pos: Vector2):
	pos += Vector2(1, 1) * CELL_SIZE / 2
	agent_sprite.offset += agent_sprite.position - pos
	agent_sprite.position = pos


# Resets episode
func reset_episode():
	trial = []
	episodes += 1
	
	update_visualization()
	
	cummulative_reward = 0


# --------------------------------------------------------------------------------------------------
# VISUALIZATION
# --------------------------------------------------------------------------------------------------

func reset_value_view():
	for value_view in value_function_holder.get_children():
		value_view.reset()
		value_view.hide()


func build_value_view():
	for tile in get_used_cells_by_id(ENVIRONMENT_LAYER, ENVIRONMENT_ID):
		if is_tile_playable(tile):
			value_function_holder.get_node_by_coord(tile).show()


func update_value_view(coord: Vector2i, value: float):
	var value_view: ValueView = value_function_holder.get_node_by_coord(coord)
	
	if value_view != null:
		value_view.set_value(value)


func reset_policy_view():
	for policy_view in policy_holder.get_children():
		policy_view.reset()
		policy_view.hide()


func build_policy_view():
	for tile in get_used_cells_by_id(ENVIRONMENT_LAYER, ENVIRONMENT_ID):
		if is_tile_playable(tile):
			policy_holder.get_node_by_coord(tile).show()


func update_policy_view(coord: Vector2i, action: Vector2i, value: float):
	var policy_view: PolicyView = policy_holder.get_node_by_coord(coord)
	
	if policy_view != null:
		policy_view.set_value(action, value)


func update_visualization():
	if g_function == null:
		g_function = Function.new([episodes], [cummulative_reward], "Reward",
			{ color = Color("#1a1817"),
				marker = Function.Marker.CIRCLE,
				type = Function.Type.SCATTER,
				interpolation = Function.Interpolation.STAIR })
		DataVisualizer.reset_functions(g_function)
	else:
		g_function.add_point(episodes, cummulative_reward)
		if g_function.count_points() > MAX_DATA_POINTS:
			g_function.remove_point(0)
	
	running_total_reward += cummulative_reward
	running_episodes += 1
	if running_episodes >= EPISODES_TO_AVERAGE:
		if averaged_function == null:
			averaged_function = Function.new([episodes], [running_total_reward / running_episodes], "Averaged reward",
				{ color = Color("#ffb303"),
					marker = Function.Marker.CIRCLE,
					type = Function.Type.LINE,
					interpolation = Function.Interpolation.LINEAR })
			DataVisualizer.add_function(averaged_function)
			DataVisualizer.viewable = true
			instructions.visible_characters = -1
			
		else:
			averaged_function.add_point(episodes, running_total_reward / running_episodes)
			if averaged_function.count_points() * EPISODES_TO_AVERAGE > MAX_DATA_POINTS:
				averaged_function.remove_point(0)
		
		running_total_reward = 0
		running_episodes = 0
