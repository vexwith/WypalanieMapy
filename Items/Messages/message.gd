extends Button

var vol_adj = 7.0
var time = 1.0
var fn = func(b, a): AudioServer.set_bus_volume_db(a, b) #bind sends args after the call args so we have to switch them

func _ready():
	set_process(false)

func _process(delta):
	SignalBus.emit_signal("message_soundproofing")

func _on_pressed():
	if not Globals.message_running:
		Globals.message_running = true
		$TextureRect.visible = !$TextureRect.visible
		$Label.visible = !$Label.visible
		
		var master_index = AudioServer.get_bus_index("Master")
		var cur_vol = AudioServer.get_bus_volume_db(master_index)
		var tween = get_tree().create_tween().set_parallel().bind_node(self)
		tween.finished.connect(_on_tween_finished)
		if $TextureRect.visible:
			var lowered_vol = cur_vol - vol_adj
			tween.tween_method(fn.bind(master_index), cur_vol, lowered_vol, time)
			Globals.open_messages += 1
		else:
			var elevated_vol = min(cur_vol + vol_adj, linear_to_db(0.8))
			tween.tween_method(fn.bind(master_index), cur_vol, elevated_vol, time)
			Globals.open_messages -= 1
		set_process(true)
			
		
func _on_tween_finished():
	Globals.message_running = false
	set_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if $TextureRect.visible:
		_on_pressed()
		await get_tree().create_timer(time).timeout
		_on_visible_on_screen_notifier_2d_screen_exited()


func _on_visibility_changed():
	_on_visible_on_screen_notifier_2d_screen_exited()
