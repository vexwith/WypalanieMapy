extends Piece

@onready var list = $KretWioska

func update(damage):
	super.update(damage)
	if stage >= 5:
		list.show()
	else:
		list.hide()
