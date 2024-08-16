extends Control

@onready var pieces = $Pieces

func _ready():
	for i in range(6):
		var piece = pieces.get_child(i)
		piece.stage = i - 1
		piece.update(0)
		
	

	
