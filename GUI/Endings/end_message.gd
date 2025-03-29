extends "res://Items/Messages/message.gd"


func _on_pressed():
	$TextureRect.visible = !$TextureRect.visible
	$Label.visible = !$Label.visible
	
	if not $TextureRect.visible:
		self.disabled = true
		get_parent().get_parent().message_clicked()
