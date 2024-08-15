extends Area2D
class_name Piece

@onready var sprite = $AnimatedSprite2D

@export var affected_pieces = []

var stage = -1 #stopień spalenia

var cursor_entered = false
#var modulation = 1.0

var clickable = true #used in first map outer pieces

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		make_move()
				
		SignalBus.emit_signal("piece_clicked", self)
	
#	if cursor_entered and event.is_action_pressed("PPM"): #test
#		undo_move()
				
func make_move():
	move(2, 1)
				
func undo_move():
	move(-2, -1)
				
func move(main, sub):
	update(main) #self update zadaje/dodaje 2 stage
		
	if not affected_pieces.is_empty():
		for piece_index in affected_pieces:
			var piece = get_parent().get_child(piece_index)
			piece.update(sub) #zależne kawałki updatują się o 1
				
func update(damage):
	if stage < 0: #if we start from -1 show sprite
		if sign(damage) == -1: #cant undo more than -1
			return
		sprite.show()
	stage = stage + damage
	if stage < 0: #in case of undoing to -1 hide
		sprite.hide()
	else:
		sprite.play(str(min(stage, 5)))
	
func update_affected(): #used only for first map outer pieces to link with others
	if not affected_pieces.is_empty():
		for index in affected_pieces:
			get_parent().get_child(index).affected_pieces.append(get_index())
			
func clear_affected(): #used when undoing first map outer pieces
	if not affected_pieces.is_empty():
		for index in affected_pieces:
			get_parent().get_child(index).affected_pieces.erase(get_index())

func _on_mouse_entered():
	cursor_entered = true
#	Globals.focused_piece = self
#	modulate.a = modulation

func _on_mouse_exited():
	cursor_entered = false
#	Globals.focused_piece = null
#	modulate.a = 1.0
