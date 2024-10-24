extends Control

var licznik = 0

func _ready():
	next_ptak()

func next_ptak():
	var next = get_child(licznik)
	next.show()
	next.animation.play("appear")
	licznik += 1
	
	match licznik:
		10:
			var mapa = find_child("PanelMap")
			mapa.show()
			mapa.animation.play("appear")
		11:
			var mapa = find_child("PanelMap")
			mapa.animation.play_backwards("appear")
#			mapa.hide()
		12:
			reset()
	
func reset():
	licznik = 0
	for i in get_children():
		i.animation.play_backwards("appear")
		i.one_shot = true
