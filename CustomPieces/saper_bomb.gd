extends Piece

@onready var bomb = $Sprite2D


func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)


func _on_piece_clicked(piece):
	if piece == self:
		if Globals.saper_count < 8:
			bomb.show()
			update(5)
