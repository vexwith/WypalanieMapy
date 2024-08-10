extends Node2D

@onready var bgm = $BGM
@onready var plaza = preload("res://Wavs/Reksio i Skarb Piratów OST - Muza1-(p).mp3")

@onready var sfx = $SFX
@onready var ojoj = preload("res://Wavs/6dziura.wav")

@onready var wide_map = $WideMapa
@onready var base_map = $WideMapa/BaseMap
@onready var exit = $Wyjście

var first_map = true
var next_piece = 17 #index of next piece used to show hidden pieces in first map
var plaza_version = 0

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
func _process(delta):
	if not bgm.playing:
		if first_map:
			match plaza_version:
				0:
					bgm.stream = plaza
				1:
					bgm.stream = plaza
			bgm.play()
	
func _on_piece_clicked(clicked_piece):
	if clicked_piece.stage == 5 or clicked_piece.stage == 6:
		sfx.stream = ojoj
		sfx.play()
	if first_map:
		#check if first map is almost done
		for i in range(1, next_piece):
			var piece = base_map.get_child(i)
			#check if youre one move away from winning then show new piece
			piece.make_move()
			if map_completed(next_piece):
				#showing new piece
				var new_piece = base_map.get_child(next_piece)
				new_piece.sprite.show()
				new_piece.stage = 0
				new_piece.sprite.play("0")
				
				next_piece += 1
				plaza_version += 1
				
				if next_piece == 27: #after getting all the closest ones change to 100 element map
					first_map = false
			piece.undo_move()
	else:
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
	#reseting all pieces
	for piece in base_map.get_children():
		if piece is Area2D:
			piece.stage = -1
			piece.sprite.hide()
	
	#reseting reset button
	exit.global_position = Vector2(1570, 953)

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
