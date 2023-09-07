extends Polygon2D


const ACCEL = 0.1


@export var inactive_pos = Vector2(0, 0)
@export var active_pos = Vector2(0, 0)


var aim_pos


@onready var mouse_identifier = $MouseIdentifier
@onready var fold: Fold = $Fold


func _ready():
	position = inactive_pos
	aim_pos = inactive_pos
	fold.connect("entered_fold", uncolapse)


func _process(delta):
	position = lerp(position, aim_pos, ACCEL)


func uncolapse():
	aim_pos = active_pos
	mouse_identifier.mouse_filter = mouse_identifier.MOUSE_FILTER_STOP


func colapse():
	aim_pos = inactive_pos
	mouse_identifier.mouse_filter = mouse_identifier.MOUSE_FILTER_IGNORE
