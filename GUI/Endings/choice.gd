extends Label

var hovered = false

func _input(event):
	if hovered and event.is_action_pressed("LPM"):
		_on_mouse_exited()
		owner.choice_clicked(self.get_index())

func _on_mouse_entered():
	hovered = true
	self.set("theme_override_colors/font_color", Color.RED)

func _on_mouse_exited():
	hovered = false
	self.set("theme_override_colors/font_color", Color.WHITE)
