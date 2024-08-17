extends Piece

@onready var bomb = $Sprite2D

var init_pos : Vector2

var tween : Tween #global tween so we can stop it

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	SignalBus.connect("rewind_bomb", _on_rewind_bomb)
	
	init_pos = global_position

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
	tween = get_tree().create_tween()
	tween.tween_property(bomb, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0).from(Color(1.0, 1.0, 1.0, 0.0))
	var x = randi_range(800, 1200)
	var y = - randi_range(300, 1000)
	tween.tween_property(bomb, "global_position", bomb.global_position + Vector2(x, y), 4.0)

func _on_rewind_bomb():
	if tween != null:
		tween.stop()
	bomb.global_position = init_pos
	bomb.hide()
