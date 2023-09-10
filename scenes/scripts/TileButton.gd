class_name TileButton
extends Sprite2D


signal select(tile_info)


@export var layer: int
@export var source_id: int
@export var atlas_coords: Vector2i


var tile_info


@onready var selection_indicator = $SelectionIndicator


func _ready():
	tile_info = {"layer": layer,
				"source_id": source_id,
				"atlas_coords": atlas_coords}


func pressed():
	SoundController.play_sfx("Click")
	
	emit_signal("select", tile_info)
	selection_indicator.show()


func deselect():
	selection_indicator.hide()
