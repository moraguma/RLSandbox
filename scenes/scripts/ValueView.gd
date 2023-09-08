class_name ValueView
extends Label


func set_value(value: float):
	text = "%.2f" % value


func reset():
	text = "N/A"
