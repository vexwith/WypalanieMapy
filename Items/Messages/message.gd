extends Button

var vol_adj = 7.0
var time = 1.0
var running = false
var fn = func(b, a): AudioServer.set_bus_volume_db(a, b) #bind sends args after the call args so we have to switch them

func _on_pressed():
	if not running:
		running = true
		$TextureRect.visible = !$TextureRect.visible
		$Label.visible = !$Label.visible
		
		var master_index = AudioServer.get_bus_index("Master")
		var cur_vol = AudioServer.get_bus_volume_db(master_index)
		var lowered_vol = cur_vol - vol_adj
		var elevated_vol = cur_vol + vol_adj
		var tween = get_tree().create_tween().bind_node(self)
		tween.finished.connect(_on_tween_finished)
		if $TextureRect.visible:
			tween.tween_method(fn.bind(master_index), cur_vol, lowered_vol, time)
		else:
			tween.tween_method(fn.bind(master_index), cur_vol, elevated_vol, time)
		
func _on_tween_finished():
	running = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	if $TextureRect.visible:
		_on_pressed()
		await get_tree().create_timer(time).timeout
		if $TextureRect.visible:
			_on_pressed()


func _on_visibility_changed():
	_on_visible_on_screen_notifier_2d_screen_exited()
