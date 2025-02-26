extends Button

@onready var mode = $Mode

var next_state = 0

func _ready():
	if owner.name == "DarkMapa":
		disabled = true

func update_buttons(gm, state):
	self.disabled = !self.disabled
	next_state = max(next_state + state, 0)
	mode.play(str(min(next_state, 3)))
	
	var other_button
	if owner.name == "DarkMapa":
		other_button = gm.blue_map.find_child("PortalButton")
	else:
		other_button = gm.dark_map.find_child("PortalButton")
	
	other_button.disabled = !other_button.disabled
	other_button.next_state = max(other_button.next_state + state, 0)
	other_button.mode.play(str(min(next_state, 3)))
	
	var dark_portal = gm.dark_pieces.get_child(0)
	var blue_portal = gm.blue_pieces.get_child(0)
	match next_state:
		0:
			dark_portal.locked = false
			blue_portal.locked = false
		1:
			dark_portal.locked = true
			blue_portal.locked = false
		2:
			dark_portal.locked = false
			blue_portal.locked = true
		3:
			dark_portal.locked = true
			blue_portal.locked = true

func _on_button_down():
	var gm = owner.get_parent()
	
	update_buttons(gm, 1)
	
	gm.sfx.stream = gm.mina_setup
	gm.sfx.play()
	
	
	
	
	
