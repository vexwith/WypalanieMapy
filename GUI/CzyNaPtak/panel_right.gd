extends Control

@onready var animation = $AnimationPlayer

var one_shot = true

func _ready():
	hide()

func _on_yes_pressed():
	if one_shot:
		one_shot = false
		get_parent().next_ptak()
		
func _on_no_pressed():
	get_parent().reset()


func _on_yes_mouse_entered():
	var p = get_parent()
	p.sfx.stream = p.tak
	p.sfx.play()

func _on_no_mouse_entered():
	var p = get_parent()
	p.sfx.stream = p.kontynuuj
	p.sfx.play()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "disappear":
		hide()

