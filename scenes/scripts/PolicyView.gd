class_name PolicyView
extends Node2D


const MAX_SIZE = 24


@onready var action_to_line = {
	Vector2i(0, -1): $Up,
	Vector2i(1, -1): $RightUp,
	Vector2i(1, 0): $Right,
	Vector2i(1, 1): $RightDown,
	Vector2i(0, 1): $Down,
	Vector2i(-1, 1): $LeftDown,
	Vector2i(-1, 0): $Left,
	Vector2i(-1, -1): $LeftUp,
}


func set_value(action: Vector2i, value: float):
	if action in action_to_line:
		action_to_line[action].set_point_position(1, Vector2(action).normalized() * clamp(value, 0, 1) * MAX_SIZE)
		action_to_line[action].show()
		
		normalize_points()


func normalize_points():
	var max_length = -INF
	
	for line in action_to_line.values():
		if line.get_point_position(1).length() > max_length:
			max_length = line.get_point_position(1).length()
	
	if max_length > 0:
		for action in action_to_line:
			var line = action_to_line[action]
			line.set_point_position(1, Vector2(action).normalized() * line.get_point_position(1).length() / max_length * MAX_SIZE)


func reset():
	for line in action_to_line.values():
		line.set_point_position(1, Vector2(0, 0))
		line.hide()
