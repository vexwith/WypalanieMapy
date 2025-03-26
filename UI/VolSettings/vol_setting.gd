extends Button

@onready var slider = $VSlider

var switcher = 1

func _ready():
	SignalBus.connect("message_soundproofing", update_slider)

func _on_pressed():
	if switcher:
		$AnimationPlayer.play("slideout")
	else:
		$AnimationPlayer.play_backwards("slideout")
	switcher = (switcher + 1) % 2
	
func update_slider():
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(slider.bus_index))
