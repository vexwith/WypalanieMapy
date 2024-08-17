extends Control



func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property($Text/Label, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label2, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label3, "modulate", Color.WHITE, 1.0)

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://UI/menu.tscn")


func reset():
	pass
