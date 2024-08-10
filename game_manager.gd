extends Node2D

@onready var wide_map = $WideMapa

func _on_reset_button_pressed():
	for piece in wide_map.find_child("BaseMap").get_children():
		if piece is Area2D:
			piece.stage = -1
			piece.sprite.hide()
