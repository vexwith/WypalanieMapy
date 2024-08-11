extends Piece


func _ready():
	clickable = false

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		make_move()
		
		#this piece swaps 18 and 20
		var first_piece = get_parent().get_child(18)
		var second_piece = get_parent().get_child(20)
		var tmp_stage = first_piece.stage
		first_piece.stage = second_piece.stage
		second_piece.stage = tmp_stage
		first_piece.sprite.play(str(min(first_piece.stage, 5)))
		second_piece.sprite.play(str(min(second_piece.stage, 5)))
				
		SignalBus.emit_signal("piece_clicked", self)


