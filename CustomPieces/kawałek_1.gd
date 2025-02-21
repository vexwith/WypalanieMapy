extends Piece

var locked = false

var swaper = 0

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		if !locked: #portal works
			SignalBus.emit_signal("blue_map_clicked")
		else: #portal is locked
			make_move()
			SignalBus.emit_signal("piece_clicked", self)
	
func update(damage):
	super.update(damage)
	
	var first_portal = owner.get_parent().dark_pieces.get_child(0)
	var second_portal = owner.get_parent().blue_pieces.get_child(0)
	if !first_portal.locked and !second_portal.locked:
		pass
	elif owner.get_parent().dark_map.visible and first_portal == self and !first_portal.locked:
		for piece in owner.get_parent().blue_pieces.get_children():
			piece.update(damage)
	elif owner.get_parent().blue_map.visible and second_portal == self and !second_portal.locked:
		for piece in owner.get_parent().dark_pieces.get_children():
			piece.update(damage)


func _on_timer_timeout():
	match swaper:
		0, 1:
			position.y += 5
		2, 3:
			position.y -= 5
	swaper = (swaper + 1) % 4
