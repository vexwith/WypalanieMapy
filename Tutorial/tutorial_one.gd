extends Control

@onready var tutorial_two = preload("res://Tutorial/tutorial_two.tscn")

@onready var pieces = $Pieces

var next = 0

func _ready():
#	for piece in pieces.get_children():
#		piece.clickable = false
	Globals.ignore_clicks = true
	get_parent().find_child("Ognik").przedmioty["lapa"] = true
	get_parent().find_child("Ognik").przedmioty["ognik"] = false

	var tween = get_tree().create_tween()
	tween.tween_property($text/Label, "modulate", Color.WHITE, 2.0)
	tween.tween_property($text/Label2, "modulate", Color.WHITE, 2.0)
	tween.tween_property($text/Label3, "modulate", Color.WHITE, 1.0)
	tween.tween_property($Button, "modulate", Color.WHITE, 1.0)



func _on_button_pressed():
	for piece in pieces.get_children():
		if piece.stage == 5:
			piece.stage = -1
			piece.update(0)
		else:
			piece.update(1)
	
	next += 1
	if next == 7:
		var tween = get_tree().create_tween()
		tween.tween_property($Button2, "modulate", Color.WHITE, 1.0)
		$Button2.show()
		


func _on_button_2_pressed():
	var tutorial = tutorial_two.instantiate()
	get_parent().find_child("TutorialOne").add_sibling(tutorial)
	queue_free()
