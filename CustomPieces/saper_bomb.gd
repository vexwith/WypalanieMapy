extends Piece

@onready var bomb = $Sprite2D


func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)


func _on_piece_clicked(piece):
	if piece == self and not Globals.bomb_clicked:
		if Globals.saper_count < 8:
			bomb.show()
			Globals.bomb_clicked = true
			await get_tree().create_timer(1.0).timeout
			owner.get_parent().sfx.stream = load("res://Wavs/explosion-91872.mp3")
			owner.get_parent().sfx.play()
			update(5)
			bomb.hide()
