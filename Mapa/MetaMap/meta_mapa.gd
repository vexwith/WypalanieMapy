extends Control

@onready var pieces = $Pieces

func _ready():
	Globals.detail_mode = true
	for i in range(len(Globals.map_pieces)):
		if Globals.map_pieces.values()[i]:
			pieces.get_child(i).clickable = true
			pieces.get_child(i).show()
		
