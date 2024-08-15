extends Control





func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://game_manager.tscn")


func _on_continue_pressed():
	pass # Replace with function body.


func _on_tutorial_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()
