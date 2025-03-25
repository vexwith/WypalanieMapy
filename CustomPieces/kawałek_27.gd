extends Piece

func update(damage):
	if stage < 0: #if we start from -1 show sprite
		if sign(damage) == -1: #cant undo more than -1
			return
	sprite.show()
	stage = stage + damage
	if stage < 0: #in case of undoing to -1 hide
		if sprite.self_modulate == Color.PALE_GREEN: #show 0 stage after undoing
			sprite.play("0")
		else:
			sprite.hide()
	else:
		sprite.play("0")
		var gm = get_parent().get_parent().get_parent()
		gm.sfx.stream = gm.ojoj
		gm.sfx.play()
