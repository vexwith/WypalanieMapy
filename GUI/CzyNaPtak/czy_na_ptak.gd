extends Control

var licznik = 0

func _ready():
	next_ptak()

func next_ptak():
	var next = get_child(licznik)
	next.show()
	next.animation.play("appear")
	licznik += 1
	
func reset():
	for i in get_children():
		i.animation.play_backwards("appear")
		i.one_shot = true
