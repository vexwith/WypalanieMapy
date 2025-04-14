extends Button

@onready var mode = $Mode

var next_state = 0

var dark_button = null
var blue_button = null
var blue_button_pos : Vector2 = Vector2(713, 1174)
var blue_mode_pos : Vector2 = Vector2(152, 50)

func _ready():
	if owner.name == "DarkMapa":
		disabled = true

func update_buttons(gm, state):
	dark_button = gm.dark_map.find_child("PortalButton")
	blue_button = gm.blue_map.find_child("PortalButton")
	
	for button in [dark_button, blue_button]:
		button.disabled = !button.disabled
		button.next_state = max(button.next_state + state, 0)
		button.mode.play(str(min(button.next_state, 3)))
	
	var dark_portal = gm.dark_pieces.get_child(0)
	var blue_portal = gm.blue_pieces.get_child(0)
	match next_state:
		0:
			dark_portal.locked = false
			blue_portal.locked = false
			update_buttons_pos(blue_button_pos, blue_mode_pos)
		1:
			dark_portal.locked = true
			blue_portal.locked = false
			update_buttons_pos(blue_button_pos, blue_mode_pos)
		2:
			dark_portal.locked = false
			blue_portal.locked = true
			var new_pos = Vector2(1539, -13)
			update_buttons_pos(new_pos, (blue_button_pos - new_pos) * blue_button.scale.x**-1 + blue_mode_pos)
		3:
			dark_portal.locked = true
			blue_portal.locked = true
			update_buttons_pos(blue_button_pos, blue_mode_pos)

func update_buttons_pos(blue_pos, bmode_pos):
	blue_button.position = blue_pos
	blue_button.mode.position = bmode_pos

func _on_button_down():
	var gm = owner.get_parent()
	
	update_buttons(gm, 1)
	
	gm.sfx.stream = gm.mina_setup
	gm.sfx.play()
	
	
	
	
	
