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
