extends Sprite2D

signal select_action(action)
signal deselect_action(action)


@export var action: Vector2i


@onready var button = $Button
@onready var selection_indicator = $SelectionIndicator


var toggled = false


func pressed():
	SoundController.play_sfx("Click")
	
	if toggled:
		untoggle()
	else:
		toggle()


func toggle():
	toggled = true
	selection_indicator.show()
	emit_signal("select_action", action)


func untoggle():
	toggled = false
	selection_indicator.hide()
	emit_signal("deselect_action", action)
