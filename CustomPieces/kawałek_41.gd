extends Piece

var swaper = 0

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		SignalBus.emit_signal("non_euclidean_clicked")
				
#		SignalBus.emit_signal("piece_clicked", self)
	
func update(damage):
	super.update(damage)
	
	for piece in owner.get_parent().non_euclidean_pieces.get_children():
		piece.update(damage)


func _on_timer_timeout():
	match swaper:
		0, 1:
			position.y += 5
		2, 3:
			position.y -= 5
	swaper = (swaper + 1) % 4
