extends Piece

@onready var audio = $AudioStreamPlayer

func _ready():
	clickable = false

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		make_move()
		
		Globals.ignore_clicks = true
		#this piece swaps 18 and 20
		var first_piece = get_parent().get_child(18)
		var second_piece = get_parent().get_child(20)
		var tmp_stage = first_piece.stage
		first_piece.stage = second_piece.stage
		second_piece.stage = tmp_stage
		
		#animation with sound
		audio.play()
		
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(first_piece, "scale", Vector2(0.1, 0.1), 0.5)
		tween.tween_property(second_piece, "scale", Vector2(0.1, 0.1), 0.5)
		
		await tween.finished
		first_piece.sprite.play(str(min(first_piece.stage, 5)))
		second_piece.sprite.play(str(min(second_piece.stage, 5)))
		
		var tween_back = get_tree().create_tween().set_parallel(true)
		tween_back.tween_property(first_piece, "scale", Vector2(0.977, -1), 0.5)
		tween_back.tween_property(second_piece, "scale", Vector2(1.0, 1.0), 0.5)
		
		await tween_back.finished
		Globals.ignore_clicks = false

		SignalBus.emit_signal("piece_clicked", self)

