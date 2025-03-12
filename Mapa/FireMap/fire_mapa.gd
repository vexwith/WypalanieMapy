extends Control

@onready var fire_scene = preload("res://Mapa/FireMap/flames.tscn")
@onready var pieces = $Pieces
@onready var spawn_timer = $SpawnTimer
@onready var spread_timer = $SpreadTimer

var LEVEL = 0

var visited_pieces = []

var spawn_time = 5.0
var spread_time = 2.0

func _ready():
	for piece in pieces.get_children():
		var fire = fire_scene.instantiate()
		piece.add_child(fire)
		fire.global_position = piece.find_child("StageNumber").global_position
		fire.hide()
		
		piece.update(3)



func _on_timer_timeout():
	LEVEL += 1
	match LEVEL:
		1, 2, 3:
			var index = randi_range(0, 15)
			var fire = pieces.get_child(index).get_child(4)
			fire.show()
			spread_timer.start()
			spawn_timer.wait_time -= 0.5
		4:
			for i in range(2):
				var index = randi_range(0, 15)
				var fire = pieces.get_child(index).get_child(4)
				fire.show()
				spread_timer.start()
			spawn_timer.wait_time -= 0.5
		
		
		
func _on_spread_timer_timeout():
	var continue_spread = false
	var visible_fires = []
	for piece in pieces.get_children():
		var fire = piece.get_child(4)
		if fire.visible:
			continue_spread = true
			piece.update(1)
			fire.hide()
			visited_pieces.append(piece.get_index())
			visible_fires.append(piece)
	
	#spread
	for piece in visible_fires:
		for index in piece.affected_pieces:
			if index not in visited_pieces:
				var affected_fire = pieces.get_child(index).get_child(4)
				affected_fire.show()
	
	if continue_spread:
		spread_timer.start()
	else:
		visited_pieces.clear()
		spawn_timer.start()






