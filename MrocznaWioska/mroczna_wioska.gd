extends Control

@onready var map = $Mapa
@onready var dark_map = $DarkMapa

func _on_mapa_pressed():
	Globals.mroczna_wioska = false
	self.hide()
	var gm = get_parent().get_parent()
	gm.wide_map.show()
	gm.bgm.stop()

func _on_dark_mapa_pressed():
	dark_map.disabled = true
	SignalBus.emit_signal("campfire_clicked")
