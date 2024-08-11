extends Piece

@onready var number = $Number

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)

func _on_piece_clicked(piece):
	if piece == self:
		number.show()
