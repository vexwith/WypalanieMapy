extends Piece

@onready var button = $Button

func update(damage):
	super.update(damage)
	if stage >= 5:
		button.show()
	else:
		button.hide()

func _on_button_button_up():
	pass
