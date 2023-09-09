extends Control


const CHART_CLASS = preload("res://addons/easy_charts/control_charts/chart.tscn")


var properties: ChartProperties
var fx: Array[Function] = []


var chart: Chart = null


var viewable = false


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
	properties.max_samples = 2000


func _process(delta):
	if viewable:
		if Input.is_action_just_pressed("graph"):
			show()
			chart.queue_redraw()
		if Input.is_action_just_released("graph"):
			hide()


func add_function(f: Function):
	fx.append(f)
	if chart == null:
		chart = CHART_CLASS.instantiate()
		add_child(chart)
		
		chart.plot(fx, properties)
	else:
		chart.load_functions(fx)


func reset_functions(f: Function):
	fx = []
	chart = null
	add_function(f)
