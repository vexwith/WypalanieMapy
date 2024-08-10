extends Node2D

@onready var wide_map = $WideMapa
@onready var exit = $Wyjście

var first_map = true

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
func _on_piece_clicked():
	if first_map:
		#check if map is done
		var win_condition = true
		for piece in wide_map.find_child("BaseMap").get_children():
			if piece is Area2D:
				if piece.stage != 3 and piece.stage != 4:
					win_condition = false
	

func _on_reset_button_pressed():
	#reseting all pieces
	for piece in wide_map.find_child("BaseMap").get_children():
		if piece is Area2D:
			piece.stage = -1
			piece.sprite.hide()
	
	#reseting reset button
	exit.global_position = Vector2(1570, 953)

func _on_wyjście_button_down():
	var x
	var y
	while true:
		x = randi_range(20, 1900)
		y = randi_range(20, 1060)
		if abs(exit.global_position.x - x) < 90 or abs(exit.global_position.y - y) < 126:
			continue
		break
	exit.global_position = Vector2(x, y)
