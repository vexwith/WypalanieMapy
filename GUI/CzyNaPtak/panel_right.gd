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


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "disappear":
		hide()
