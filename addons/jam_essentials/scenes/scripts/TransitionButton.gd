extends Button


@export var transition_path: String


func _pressed():
	SoundController.play_sfx("Click")
	SceneManager.goto_scene(transition_path)
