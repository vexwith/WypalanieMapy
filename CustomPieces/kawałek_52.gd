extends Piece

@onready var trap = $Trap

func update(damage):
	super.update(damage)
	if not Globals.return_trapped and stage >= 5:
		trap.show()
		trap.set_collision_mask_value(1, true)
	
