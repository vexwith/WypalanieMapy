extends Control

@onready var sfx = $SFX
@onready var czy = preload("res://Wavs/Nar_F122.wav")
@onready var tak = preload("res://Wavs/Nar_F123.wav")
@onready var kontynuuj = preload("res://Wavs/Nar_F115.wav")
@onready var niemam = preload("res://Wavs/Nar_F125.wav")

var licznik = 0

func _ready():
	SignalBus.connect("ptak_event", _on_ptak_event)

func next_ptak():
	if licznik == 11:
		reset()
		sfx.stream = niemam
		sfx.play()
		return
	
	sfx.stream = czy
	sfx.play()
	
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
			mapa.animation.play("disappear")
			await mapa.animation.animation_finished
			mapa.hide()

	
func reset():
	licznik = 0
	for i in get_children():
		if i is AudioStreamPlayer:
			return
		i.animation.play("disappear")
		i.one_shot = true
		
func _on_ptak_event():
	if licznik == 0:
		next_ptak()
