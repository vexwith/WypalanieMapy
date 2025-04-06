extends Control

@onready var map = $Mapa
@onready var dark_map = $DarkMapa
@onready var fake_list = $FakeList
@onready var timer = $Timer

var fake_index = 0

func _on_mapa_pressed():
	Globals.mroczna_wioska = false
	self.hide()
	var gm = get_parent().get_parent()
	gm.wide_map.show()
	gm.bgm.stop()

func _on_dark_mapa_pressed():
	dark_map.disabled = true
	SignalBus.emit_signal("campfire_clicked")


func _on_fake_mapa_pressed():
	if not fake_list.get_child(0).visible:
		timer.start()

func _on_timer_timeout():
	fake_list.get_child(fake_index).show()
	fake_index += 1
	if fake_index < fake_list.get_children().size():
		timer.start()


func _on_fake_mapa_6_pressed():
	for i in fake_list.get_child(4).get_children():
		i.visible = !i.visible
