extends Button

var vol_adj = 7.0

func _on_pressed():
	$TextureRect.visible = !$TextureRect.visible
	$Label.visible = !$Label.visible
	
	if $TextureRect.visible:
		Bgm.volume_db -= vol_adj
	else:
		Bgm.volume_db += vol_adj
