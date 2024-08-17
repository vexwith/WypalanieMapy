extends Control

@onready var tutorial_two = preload("res://Tutorial/tutorial_two.tscn")
@onready var tutorial_three = preload("res://Tutorial/tutorial_three.tscn")
@onready var tutorial_four = preload("res://Tutorial/tutorial_four.tscn")

func _on_reset_pressed():
	get_child(1).reset()
