extends Piece

@export var next_arrow : int #index of next piece with arrow

@onready var circle = $Circle
@onready var arrow = $Arrow

var arrow_event : bool = false :
	get:
		return arrow_event
	set(value):
		arrow_event = value
		stage = 0
		update(0)
		if get_index() == 70:
			arrow = $Treasure

func _ready():
	super._ready()
	
	if get_index() != 70: circle.hide()
	arrow.hide()

func update(damage):
	if stage < 0: #if we start from -1 show sprite
		if sign(damage) == -1: #cant undo more than -1
			return
		sprite.show()
	stage = stage + damage
	if stage < 0: #in case of undoing to -1 hide
		if sprite.self_modulate == Color.PALE_GREEN: #show 0 stage after undoing
			sprite.play("0")
		else:
			sprite.hide()
	else:
		sprite.play(str(min(stage, 5)))
		if arrow_event or get_index() == 70:
			if stage >= 5:
				circle.hide()
				arrow.show()
			else:
				circle.show()
				arrow.hide()


func _on_arrow_pressed():
	get_parent().get_child(next_arrow).arrow_event = true
	arrow.disabled = true


func _on_treasure_pressed():
	arrow.disabled = true
	Globals.treasure = true
	SignalBus.emit_signal("piece_clicked", get_parent().get_child(100))
