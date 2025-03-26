extends "res://Items/Messages/message.gd"


func _physics_process(delta):
	rotation_degrees += delta
	position += Vector2(-delta, delta)
