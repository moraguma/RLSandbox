extends Learner


var state_action_value = {}
var state_action_frequency = {}
var gamma = 0.9
var starting_epsilon = 0.9
var episodes_to_zero = 200
var episodes = 0


# trial is a list of [s, a, r]
func rl_step(trial: Array, is_terminal: bool, env: RLEnvironment) -> void:
	# Will only run is update if the episode has ended
	if is_terminal:
		episodes += 1
		
		# Prediction
		var G = 0
		for i in range(len(trial) - 2, -1, -1):
			var s = trial[i][0]
			var a = trial[i][1]
			var r = trial[i + 1][2]
			
			G = gamma * G + r
			
			init_state_action(state_action_value, s, a)
			init_state_action(state_action_frequency, s, a)
			state_action_value[s][a] = (state_action_frequency[s][a] * state_action_value[s][a] + G) / (state_action_frequency[s][a] + 1)
			state_action_frequency[s][a] += 1
			
			# Updates value function visualization -------------------------------------------------
			update_view_qs(state_action_value, s, env)

# Graph, current state
# g[state][action] is a list of [resulting state, probability]
func select_action(s: Vector2i, ax: Array[Vector2i], env: RLEnvironment) -> Vector2i:
	var r = randf()
	if r <= linear_decrease(starting_epsilon, episodes_to_zero, episodes):
		return ax[randi() % len(ax)]
	
	var max_v = -INF
	var best_a: Vector2i
	
	for a in ax:
		init_state_action(state_action_value, s, a)
		
		if state_action_value[s][a] > max_v:
			max_v = state_action_value[s][a]
			best_a = a
	
	return best_a


func init_state_action(d: Dictionary, s: Vector2i, a: Vector2i):
	if not s in d:
		d[s] = {}
	if not a in d[s]:
		d[s][a] = 0
