extends Piece

@export var next_arrow : int #index of next piece with arrow

@onready var circle = $Circle
@onready var arrow = $Arrow
@onready var zloto = self.find_child("Zloto")

var starting_piece = 70

var arrow_event : bool = false :
	get:
		return arrow_event
	set(value):
		arrow_event = value
		stage = 0
		update(0)
		if get_index() == starting_piece:
			arrow = $Treasure

func _ready():
	super._ready()
	circle.modulate.a = 0.4
	
	if get_index() != starting_piece: circle.hide()
	arrow.hide()

func update(damage):
	super.update(damage)
	if arrow_event or get_index() == starting_piece:
		if stage >= 5:
			circle.hide()
			arrow.show()
			if get_index() == starting_piece:
				if arrow == $Treasure: return
			_on_arrow_pressed()
		else:
			circle.modulate.a += 0.2
			circle.show()
			arrow.hide()
			if get_index() == starting_piece: zloto.hide()


func _on_arrow_pressed():
	get_parent().get_child(next_arrow).arrow_event = true
	arrow.disabled = true


func _on_treasure_pressed():
	zloto.show()
	arrow.disabled = true
	Globals.treasure = true
	SignalBus.emit_signal("piece_clicked", get_parent().get_child(100))
