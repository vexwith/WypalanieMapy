extends Piece

@onready var number = $Number
var one_shot = true # we need to click every number at least one time

func _ready():
	super._ready()
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	SignalBus.connect("rewind_numbers", _on_rewind_numbers)

func _on_piece_clicked(piece):
	if piece == self and not Globals.bomb_clicked:
		owner.get_parent().saper_failed() # check if this click burned some other piece
		
		if one_shot:
			one_shot = false
			number.show()
			Globals.saper_count += 1
			
			if Globals.saper_count == 8:
				for i in range(25, 40):
					var bomb = get_parent().get_child(i)
					if 'bomb' in bomb:
						bomb.bomb_vanish()

func _on_rewind_numbers():
	number.hide()
	one_shot = true
