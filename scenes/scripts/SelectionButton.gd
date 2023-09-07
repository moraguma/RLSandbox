extends Button


signal select(selection)


@export var selection: String


func _pressed():
	emit_signal("select", selection)
	disabled = true


func deselect():
	disabled = false
