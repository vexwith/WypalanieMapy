extends Control

@onready var animation = $AnimationPlayer
@onready var map_piece = $Map

var one_shot = true

func _ready():
	hide()
	
	if Globals.map_pieces["ptak_event"] == true:
		map_piece.hide()

func _on_map_button_up():
	map_piece.hide()
	get_parent().reset()
	Globals.ptak_event = true
	SignalBus.emit_signal("get_small_piece")
