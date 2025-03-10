extends Piece

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		var fire = get_child(4)
		fire.hide()
