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
	Vector2i(-1, 0): Vector2i(0, 2)
}
const TILE_TO_ACTION = {
	Vector2i(0, 0): Vector2i(0, -1),
	Vector2i(0, 1): Vector2i(1, 0),
	Vector2i(0, 3): Vector2i(0, 1),
	Vector2i(0, 2): Vector2i(-1, 0)
}

const MAX_H = 13
const MAX_V = 7

# Agent data -------------------------------------------------------------------
const AGENT_SPRITE_DEFAULT_OFFSET = Vector2(0, -32)
const AGENT_SPRITE_LERP_WEIGHT = 0.3

# Rendering --------------------------------------------------------------------
const MIN_FRAMES_PER_ITERATION = 1
const MAX_FRAMES_PER_ITERATION = 60

# Learning ---------------------------------------------------------------------
const MAX_ITERATIONS = 10000

# --------------------------------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------------------------------

# Environment ------------------------------------------------------------------
@export var start_random = true
var graph = {}
var done = false

var trial = [] # List of [s, a, r]
var iterations = 0

# Components -------------------------------------------------------------------
@export var action_results_script: GDScript
@onready var action_results: ActionResults = action_results_script.new()

@export var resetter_script: GDScript
@onready var resetter: Resetter = resetter_script.new()

@export var rewarder_script: GDScript
@onready var rewarder: Rewarder = rewarder_script.new()

@export var learner_script: GDScript
@onready var learner: Learner = learner_script.new()

# Rendering --------------------------------------------------------------------
@export var headless = true
@export var keep_running = true
var frames_passed = 0

# --------------------------------------------------------------------------------------------------
# NODES
# --------------------------------------------------------------------------------------------------

@onready var agent_sprite = $Agent
@onready var speed_slider = $Speed

# --------------------------------------------------------------------------------------------------
# BUILT-INS
# --------------------------------------------------------------------------------------------------

func _ready():
	randomize()
	
	build_graph()
	
	if headless:
		while iterations < MAX_ITERATIONS:
			_iterate_algorithm()


func _process(delta):
	agent_sprite.offset = lerp(agent_sprite.offset, AGENT_SPRITE_DEFAULT_OFFSET, AGENT_SPRITE_LERP_WEIGHT)
	
	if not done or keep_running:
		frames_passed += 1
		
		if frames_passed >= MAX_FRAMES_PER_ITERATION - (MAX_FRAMES_PER_ITERATION - MIN_FRAMES_PER_ITERATION) * speed_slider.value:
			frames_passed = 0
			
			done = _iterate_algorithm()


# Calls function for the chosen RL algorithm
func _iterate_algorithm():
	iterations += 1
	
	environment_step()
	
	learner.rl_step(trial[-2][0], trial[-2][1], trial[-1][0], trial[-1][2], is_terminal(trial[-1][0]))
	
	if is_terminal([-1][0]):
		reset_episode()


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


# Gets the resulting tile of a movement as a Vector2i
func get_movement_result(start, action):
	if get_cell_atlas_coords(ENVIRONMENT_LAYER, start + action) == WALL_TILE:
		return start
	return start + action


# Checks if this state is terminal
func is_terminal(state):
	return get_cell_atlas_coords(OBJECT_LAYER, state) in [WIN_TILE, LOSE_TILE]


# Takes a step in a trial according to its learner. If a trial isn't
# running, places the agent in a random position.
func environment_step():
	var past_state
	var past_action
	var current_state
	var reward_signal
	
	if len(trial) == 0:
		past_state = null
		past_action = null
		
		current_state = resetter.get_initial_tile(graph)
		reward_signal = rewarder.get_reward(self, current_state)
		
		move_to(current_state)
	else:
		trial[-1][1] = learner.select_action(graph, current_state)
		
		past_state = trial[-1][0]
		past_action = trial[-1][1]
		
		take_step(past_state, past_action)


# Takes a step considering the specified action and returns the result based on 
# the random resulting state
func take_step(state, action):
	var r = randf()
	
	for result_probability in graph[state][action]:
		if r <= result_probability[1]:
			move_to(get_movement_result(state, result_probability[0]))
		r -= result_probability[1]


# Moves agent to specified state and updates trial with new state and reward
func move_to(state):
	trial.append([state, null, rewarder.get_reward(self, state)])
	
	move_agent_to(Vector2(state) * CELL_SIZE)


func move_agent_to(pos: Vector2):
	pos += Vector2(1, 1) * CELL_SIZE / 2
	agent_sprite.position = pos
	
	if not OS.is_debug_build():
		agent_sprite.offset += agent_sprite.position - pos


# Resets episode
func reset_episode():
	trial = []
	# TODO: Implement cumulative reward CSV generation
