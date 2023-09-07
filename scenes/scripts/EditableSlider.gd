extends HSlider


signal update_property(name, value)


@export var property: String

@onready var value_label = $Value
@onready var min_label = $Min
@onready var max_label = $Max
@onready var property_label = $Property


func _ready():
	min_label.text = str(min_value)
	max_label.text = str(max_value)
	value_label.text = str(value)
	property_label.text = property


func update_value(value):
	value_label.text = str(value)
	emit_signal("update_property", property, value)
