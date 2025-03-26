extends VSlider

var bus_index : int

func _ready():
	bus_index = AudioServer.get_bus_index("Master")
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
func _on_value_changed(slider_value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(slider_value))
