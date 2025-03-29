extends "res://Items/Messages/message.gd"


func _on_tween_finished():
	await get_tree().create_timer(4.0).timeout
	AudioServer.set_bus_volume_db(0, AudioServer.get_bus_volume_db(0) + 7.0 * Globals.open_messages)
	Globals.open_messages = 0
	Globals.message_running = false
	get_tree().quit()
