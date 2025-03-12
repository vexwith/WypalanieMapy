extends AnimatedSprite2D




func _on_timer_timeout():
	if not $AudioStreamPlayer.playing and visible:
		$AudioStreamPlayer.play()
	elif not visible:
		$AudioStreamPlayer.stop()
