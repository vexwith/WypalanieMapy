extends Control

@onready var animation = $AnimationPlayer
@onready var sfx = $AudioStreamPlayer

func _ready():
	hide()
	
func run():
	show()
	animation.play("appear")
	sfx.play()

func _on_map_pressed():
	Globals.ignore_clicks = false
	animation.play("disappear")


