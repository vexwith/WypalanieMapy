extends Button




func _on_pressed():
	$TextureRect.visible = !$TextureRect.visible
	$Label.visible = !$Label.visible
	
	$TextureRect.global_position
