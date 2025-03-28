extends Control

@onready var fire_scene = preload("res://Mapa/FireMap/flames.tscn")
@onready var pieces = $Pieces
@onready var spawn_timer = $SpawnTimer
@onready var spread_timer = $SpreadTimer
@onready var return_timer = $Return
@onready var label = $Waves
@onready var warning = $Warning

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

func spawn_flame(number):
	var indexes = []
	for i in range(number):
		var index : int
		while true:
			index = randi_range(0, 15)
			if index not in indexes:
				break
		indexes.append(index)
		var fire = pieces.get_child(index).get_child(4)
		fire.show()
	spread_timer.start()

func _on_timer_timeout():
	LEVEL += 1
	label.text = str(11-LEVEL)
	match LEVEL:
		1, 2, 3:
			spawn_flame(1)
			spawn_timer.wait_time -= 0.5
			spread_timer.wait_time -= 0.25
		4, 5:
			spawn_flame(2)
			spawn_timer.wait_time -= 0.5
			spread_timer.wait_time -= 0.15
		6, 7:
			spawn_flame(2)
			spawn_timer.wait_time -= 0.2
		8, 9, 10, 11:
			spawn_flame(3)
		
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
		var flag = true
		for piece in pieces.get_children():
			if piece.stage >= 5:
				flag = false
		if flag:
			spread_timer.start()
		else:
			get_parent().sfx.stream = get_parent().ojoj
			get_parent().sfx.play()
	else:
		visited_pieces.clear()
		if LEVEL == 11:
			if completed():
				get_parent().reset.hide()
				label.hide()
				var tween = get_tree().create_tween().set_parallel()
				tween.bind_node(self)
				var t = 1.0
				tween.tween_property(pieces, "scale", Vector2(0, 0), t)
				tween.tween_property(pieces, "position", Vector2(960, 540), t)
				tween.tween_property($BKG, "scale", Vector2(0, 0), t)
				tween.tween_property($BKG, "position", Vector2(960, 540), t)
				await tween.finished
				Globals.map_saved = true
				SignalBus.emit_signal("get_small_piece")
				return_timer.start()
			else:
				warning.modulate.a = 0.0
				warning.show()
				var tween = get_tree().create_tween().bind_node(self)
				tween.tween_property(warning, "modulate", Color.WHITE, 1.0)
		else:
			spawn_timer.start()

func completed():
	for piece in pieces.get_children():
		if piece.stage not in [3, 4]:
			return false
	return true

func _on_return_timeout():
	get_parent()._on_menu_pressed()
