extends Control


var properties: ChartProperties
var fx: Array[Function] = []


@onready var chart: Chart = $Chart


var initialized = false


func _ready():
	properties = ChartProperties.new()
	properties.font = load("res://resources/fonts/foo.otf")
	properties.colors.frame = Color("#d4d4d4")
	properties.colors.background = Color.TRANSPARENT
	properties.colors.grid = Color("#524f4e")
	properties.colors.ticks = Color("#524f4e")
	properties.colors.text = Color("#1a1817")
	properties.draw_bounding_box = false
	properties.show_legend = true
	properties.title = "Reward over time"
	properties.x_label = "Episodes"
	properties.y_label = "Cummulative reward"
	properties.x_scale = 5
	properties.y_scale = 10
	properties.max_samples = 1000


func _process(delta):
	if initialized:
		if Input.is_action_just_pressed("ui_accept"):
			show()
			chart.queue_redraw()
		if Input.is_action_just_released("ui_accept"):
			hide()


func add_function(f: Function):
	fx.append(f)
	if not initialized:
		initialized = true
		
		chart.plot(fx, properties)
	else:
		chart.load_functions(fx)


func reset_functions(f: Function):
	fx = []
	add_function(f)
