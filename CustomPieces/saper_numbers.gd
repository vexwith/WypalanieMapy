extends Piece

@onready var number = $Number

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	SignalBus.connect("rewind_numbers", _on_rewind_numbers)

func _on_piece_clicked(piece):
	if piece == self and not Globals.bomb_clicked:
		number.show()
		Globals.saper_count += 1
		
		owner.get_parent().saper_failed()

func _on_rewind_numbers():
	number.hide()
