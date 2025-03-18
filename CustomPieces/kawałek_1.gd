extends Piece

var locked = false :
	get:
		return locked
	set(value):
		locked = value
		update(0)
		
		if locked:
			affected_pieces.clear()
			update_affected()
		else:
			affected_pieces.clear()

var swaper = 0


func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		if !locked: #portal works
			SignalBus.emit_signal("blue_map_clicked")
		else: #portal is locked
			make_move()
			SignalBus.emit_signal("piece_clicked", self)
	
func update(damage):
	#base update changed
	if stage < 0: #if we start from -1 show sprite
		if sign(damage) == -1: #cant undo more than -1
			return
		sprite.show()
	stage = stage + damage
	if stage < 0: #in case of undoing to -1 hide
		if sprite.self_modulate == Color.PALE_GREEN: #show 0 stage after undoing
			if locked:
				sprite.play("6")
			else:
				sprite.play("0")
		else:
			sprite.hide()
	elif locked:
		sprite.play(str(min(stage + 6, 11)))
	else:
		sprite.play(str(min(stage, 5)))
	
	#portal stuff
	var gm = owner.get_parent()
	
	var first_portal = gm.dark_pieces.get_child(0)
	var second_portal = gm.blue_pieces.get_child(0)
	if !first_portal.locked and !second_portal.locked: #infinity
		if damage < 1: return #dont activate again when going back
		var  temp_detail_mode = Globals.detail_mode
		Globals.detail_mode = false
		gm.clear_rims(gm.dark_pieces)
		gm.clear_rims(gm.blue_pieces)
		for piece in gm.blue_pieces.get_children(): #blocking everything
			piece.clickable = false
			get_index()
			piece.sprite.play(str(5))
		for piece in gm.dark_pieces.get_children():
			piece.clickable = false
#			print(piece.get_index())
			piece.sprite.play(str(5))
		Globals.undraggable = true
		
#		gm.ognik.dark_mode = false
		ojojoj()
		var white_shadow = gm.white_shadow #flashbang
		white_shadow.show()
		var tween = get_tree().create_tween().set_parallel(true).bind_node(self)
		var t = 2.0
		tween.tween_property(white_shadow, "modulate", Color(1.0, 1.0, 1.0, 1.0), t).set_trans(Tween.TRANS_SINE)
		if gm.blue_map.visible: #Color(0, 0, 0.451)
			tween.tween_property(owner.find_child("CanvasModulate"), "color", Color.WHITE, t)
		else:
			tween.tween_property(gm.ognik.light, "scale", Vector2(3.0, 3.0), t)
			tween.tween_property(gm.ognik.light, "color", Color.WHITE, t)
		await tween.finished
		
		var infinity = gm.infinity #placing infinity sign
		infinity.show()
		infinity.global_position = gm.camera.global_position - Vector2(1080, 620)
		
		var tween2 = get_tree().create_tween().bind_node(self) #end flashbang
		tween2.tween_property(white_shadow, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0)
		await tween2.finished
		white_shadow.hide()
		
		Globals.detail_mode = temp_detail_mode
		
	elif gm.dark_map.visible and first_portal == self and !first_portal.locked:
		for piece in gm.blue_pieces.get_children():
			piece.update(damage)
			if piece.stage == 5 or piece.stage == 6:
				gm.sfx.stream = gm.ojoj
				gm.sfx.play()
	elif gm.blue_map.visible and second_portal == self and !second_portal.locked:
		for piece in gm.dark_pieces.get_children():
			piece.update(damage)
			if piece.stage == 5 or piece.stage == 6:
				gm.sfx.stream = gm.ojoj
				gm.sfx.play()
			
func update_affected(): #used only for first map outer pieces to link with others
	for piece in get_parent().get_children():
		if 0 in piece.affected_pieces:
			affected_pieces.append(piece.get_index())
			
func ojojoj():
	var gm = owner.get_parent()
	gm.sfx.stream = gm.ojoj
	for i in range(8):
		gm.sfx.play()
		await get_tree().create_timer(0.15).timeout

func _on_timer_timeout():
	match swaper:
		0, 1:
			position.y += 5
		2, 3:
			position.y -= 5
	swaper = (swaper + 1) % 4
