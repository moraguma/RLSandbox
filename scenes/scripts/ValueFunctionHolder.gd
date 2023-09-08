extends Node2D


const ROW_SIZE = 13


func get_node_by_coord(coord: Vector2i) -> ValueView:
	var true_coord = coord - Vector2i(1, 1)
	var n = true_coord[1] * ROW_SIZE + true_coord[0] + 1
	
	return get_node_or_null(str(n))
