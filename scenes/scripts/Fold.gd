class_name Fold
extends Node2D


signal entered_fold


func enter_fold():
	emit_signal("entered_fold")
