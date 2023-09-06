extends Learner


var q = {}
var gamma = 0.9
var starting_epsilon = 0.9
var episodes_to_zero_epsilon = 200
var starting_alpha = 0.1
var episodes_to_zero_alpha = 200
var episodes = 0

var past_ax
var na


# trial is a list of [s, a, r]
func rl_step(trial: Array, is_terminal: bool) -> void:
	# Will only update after an action has been taken
	if len(trial) >= 2:
		var s = trial[-2][0]
		var ns = trial[-1][0]
		var a = trial[-2][1]
		var r =  trial[-1][2]
		na = select_action(ns, past_ax)
		
		init_q(q, s, a, false)
		init_q(q, ns, na, is_terminal)
		
		var td_error = r + gamma * q[ns][na] - q[s][a]
		q[s][a] += linear_decrease(starting_alpha, episodes_to_zero_alpha, episodes) * td_error
	if is_terminal:
		na = null
		episodes += 1


# q[s][a] is the q value of s, a
func select_action(s: Vector2i, ax: Array[Vector2i]) -> Vector2i:
	past_ax = ax
	
	if na != null:
		var a = na
		na = null
		return a
	
	var r = randf()
	if r <= linear_decrease(starting_epsilon, episodes_to_zero_epsilon, episodes):
		return ax[randi() % len(ax)]
	
	var max_v = -INF
	var best_a: Vector2i
	
	for a in ax:
		init_q(q, s, a, false)
		
		if q[s][a] > max_v:
			max_v = q[s][a]
			best_a = a
	
	return best_a


func init_q(d: Dictionary, s: Vector2i, a: Vector2i, is_terminal: bool):
	if not s in d:
		d[s] = {}
	if not a in d[s]:
		if is_terminal:
			d[s][a] = 0
		else:
			d[s][a] = randf()
