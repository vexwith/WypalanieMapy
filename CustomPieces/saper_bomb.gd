extends Piece

@onready var bomb = $Sprite2D


func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)


func _on_piece_clicked(piece):
	if piece == self and not Globals.bomb_clicked:
		if Globals.saper_count < 8:
			bomb.show()
			Globals.bomb_clicked = true
			var gm = owner.get_parent()
			gm.sfx.stream = gm.mina_setup
			gm.sfx.play()
			await gm.sfx.finished
			gm.sfx.stream = gm.mina_wybuch
			gm.sfx.play()
			update(5)
			bomb.hide()

func bomb_vanish():
	bomb.show()
	var tween = get_tree().create_tween()
	tween.tween_property(bomb, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0).from(Color(1.0, 1.0, 1.0, 0.0))
	var x = randi_range(800, 1200)
	var y = - randi_range(300, 1000)
	tween.tween_property(bomb, "global_position", bomb.global_position + Vector2(x, y), 4.0)
