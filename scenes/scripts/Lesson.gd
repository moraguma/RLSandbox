extends Polygon2D


const LERP_WEIGHT = 0.1
const SHOW_POS = Vector2(0, 0)
const HIDE_POS = Vector2(528, 0)
const TOLERANCE = 5


var aim_pos = SHOW_POS


func _process(delta):
	position = lerp(position, aim_pos, LERP_WEIGHT)
	if aim_pos == HIDE_POS and (position - HIDE_POS).length() < TOLERANCE:
		queue_free()


func leave():
	aim_pos = HIDE_POS
