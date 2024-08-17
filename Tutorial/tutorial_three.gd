extends Control

@onready var pieces = $Pieces

var map_state_log = []

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
	save_prev()
	
	var tween = get_tree().create_tween()
	tween.tween_property($Text/Label, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label2, "modulate", Color.WHITE, 2.0)
	
func _input(event):
	if event.is_action_pressed("rewind"):
		if len(map_state_log) > 1:
			map_state_log.pop_back()
			var prev_state = map_state_log[-1].duplicate()
			load_prev(prev_state)
		elif len(map_state_log) == 1:
			var prev_state = map_state_log[-1].duplicate()
			load_prev(prev_state)
	
func _on_piece_clicked(clicked_piece):
	var win_condition = true
	for piece in pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			win_condition = false
			
	save_prev()
	
	if win_condition:
		var tutorial = get_parent().tutorial_four.instantiate()
		get_parent().get_child(1).add_sibling(tutorial)
		queue_free()
	
func save_prev():
	var map_state = []
	for piece in pieces.get_children():
		map_state.append(piece.stage)
	map_state_log.append(map_state)
	
func load_prev(map_state):
	for i in range(len(map_state) - 1, -1, -1):
		var piece = pieces.get_child(i)
		piece.stage = map_state.pop_back()
		piece.update(0)
	
func reset():
	for piece in pieces.get_children():
		piece.stage = -1
		piece.update(0)
