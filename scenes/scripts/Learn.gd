extends Node2D


var current_lesson = null
var current_button = null


var lessons = {}


func _ready():
	for button in $Lessons/VBox.get_children():
		if not button.selection in lessons:
			lessons[button.selection] = load(button.selection)
		button.connect("select", select_lesson.bind(button))


func select_lesson(path, button):
	if current_lesson != null:
		current_lesson.leave()
	if current_button != null:
		current_button.deselect()
	
	current_lesson = lessons[path].instantiate()
	add_child(current_lesson)
	
	current_button = button
