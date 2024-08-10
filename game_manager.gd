extends Node2D

@onready var bgm = $BGM
@onready var plaza = preload("res://Wavs/Reksio i Skarb Piratów OST - Muza1-(p).mp3")

@onready var sfx = $SFX
@onready var ojoj = preload("res://Wavs/6dziura.wav")

@onready var wide_map = $WideMapa
@onready var base_map = $WideMapa/BaseMap
@onready var first_bkg = $WideMapa/BaseMap/FirstBackground
@onready var exit = $Wyjście

var first_map = true
var MAX_PIECES = 24 #all pieces including hidden on the first map + 1
var next_piece = 17 #index of next piece used to show hidden pieces in first map
var plaza_version = 0
var max_modulation = 1.0 #max modulation of first map

var between_maps = true

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	MAX_PIECES = base_map.get_child_count()
	
func _process(delta):
	#bgm handler
	if not bgm.playing:
		if first_map:
			bgm.stream = plaza
		bgm.play()
	#slowing down plaza
	if between_maps:
		match plaza_version:
			0:
				bgm.pitch_scale = 1.0
			1:
				bgm.pitch_scale = 0.95
			2:
				bgm.pitch_scale = 1.05
			3:
				bgm.pitch_scale = 0.90
			4:
				bgm.pitch_scale = 0.85
			5:
				bgm.pitch_scale = 0.80
			6:
				bgm.pitch_scale = 0.70
			7:
				bgm.pitch_scale = 0.65
			8:
				bgm.pitch_scale = 0.15
				
	#bkg handler
	if first_bkg.modulate.a > max_modulation:
		first_bkg.modulate.a -= 0.001
	
func _on_piece_clicked(clicked_piece):
	if clicked_piece.stage == 5 or clicked_piece.stage == 6:
		sfx.stream = ojoj
		sfx.play()
	if first_map:
		#check if first map is almost done
		var map_uncompleted = true
		while first_map and map_uncompleted:
			map_uncompleted = false
			for i in range(1, next_piece):
				var piece = base_map.get_child(i)
				#check if youre one move away from winning then show new piece
				piece.make_move()
				if map_completed(next_piece):
					piece.undo_move()
					map_uncompleted = true
					#showing new piece
					var new_piece = base_map.get_child(next_piece)
					new_piece.sprite.show()
					new_piece.stage = 1 #starts on second stage
					new_piece.sprite.play(str(new_piece.stage))
					if new_piece.clickable == false:
						new_piece.update_affected()
						new_piece.clickable = true
					
					next_piece += 1
					plaza_version += 1
					
					max_modulation -= 0.15
					
					if next_piece == MAX_PIECES: #after getting all the closest ones change to 100 element map
						first_map = false
						
				else:
					piece.undo_move()
	elif between_maps:
		if map_completed(base_map.get_child_count()):
			print("nice")

func map_completed(search_range):
	#check if map is done	
	var win_condition = true
	for i in range(1, search_range):
		var piece = base_map.get_child(i)
		if piece.stage != 3 and piece.stage != 4:
			return false
			
	return win_condition

func _on_reset_button_pressed():
	get_tree().reload_current_scene()
#	#return visibility
#	max_modulation = 1.0
#	first_bkg.modulate.a = 1.0
#
#	#reseting all pieces
#	for piece in base_map.get_children():
#		if piece is Area2D:
#			piece.stage = -1
#			piece.sprite.hide()
#
#	#reseting reset button
#	exit.global_position = Vector2(1570, 953)
#
#	#reseting hidden pieces progress
#	first_map = true
#	next_piece = 17
#
#	#reset audio to normal
#	plaza_version = 0

func _on_wyjście_button_down():
	var x
	var y
	while true:
		x = randi_range(20, 1900)
		y = randi_range(20, 1060)
		if abs(exit.global_position.x - x) < 90 or abs(exit.global_position.y - y) < 126:
			continue
		break
	exit.global_position = Vector2(x, y)
