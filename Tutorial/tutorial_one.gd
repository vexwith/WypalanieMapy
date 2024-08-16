extends Control

@onready var pieces = $Pieces

func _ready():
	for piece in pieces.get_children():
		piece.clickable = false



