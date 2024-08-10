extends Area2D
class_name Piece

@onready var sprite = $AnimatedSprite2D

@export var affected_pieces = []

var stage = -1 #stopień spalenia

var cursor_entered = false
var modulation = 1.0

func _input(event):
	if cursor_entered and event.is_action_pressed("LPM"):
		update(2) #self update zadaje 2 dmg
		
		if not affected_pieces.is_empty():
			for piece_index in affected_pieces:
				var piece = get_parent().get_child(piece_index)
				piece.update(1) #zależne kawałki updatują się o 1
				
func update(damage):
	if stage < 0:
		sprite.show()
	stage = min(stage + damage, 6)
	sprite.play(str(min(stage, 5)))

func _on_mouse_entered():
	cursor_entered = true
#	Globals.focused_piece = self
	modulate.a = modulation

func _on_mouse_exited():
	cursor_entered = false
#	Globals.focused_piece = null
	modulate.a = 1.0
