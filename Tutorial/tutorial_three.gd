extends Control

@onready var pieces = $Pieces

var map_state_log = []
var map_log_index = 0

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
	save_prev()
	
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property($Text/Label, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label2, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label3, "modulate", Color.WHITE, 1.0)
	
func _input(event):
			
	if (event.is_action_pressed("rewind") or event.is_action_pressed("rewind_camera")):
		var direction = -1 if event.is_action_pressed("rewind") else 1
		#out of bounds
		if (map_log_index == 0 and direction == -1) or \
		(map_log_index == len(map_state_log)-1 and direction == 1):
			var prev_state = map_state_log[map_log_index].duplicate()
			load_prev(prev_state)
		#going both ways
		else:
			map_log_index += direction 
			var prev_state = map_state_log[map_log_index].duplicate()
			load_prev(prev_state)
			
	if event.is_action_pressed("restart"):
		reset()
			
	if event.is_action_pressed("ctrl"):
		Globals.detail_mode = !Globals.detail_mode
	
func _on_piece_clicked(clicked_piece):
	var win_condition = true
	for piece in pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			win_condition = false
			
	save_prev()
	
	if win_condition:
		get_parent().sfx.stream = get_parent().win
		get_parent().sfx.play()
		await get_parent().sfx.finished
		var tutorial = get_parent().tutorial_four.instantiate()
		get_parent().get_child(1).add_sibling(tutorial)
		queue_free()
	
func save_prev():
	var map_state = []
	for piece in pieces.get_children():
		map_state.append(piece.stage)
		
	map_state_log = map_state_log.slice(0, map_log_index+1) #cutting alternative branches
	map_state_log.append(map_state)
	map_log_index = len(map_state_log) - 1
	
func load_prev(map_state):
	for i in range(len(map_state) - 1, -1, -1):
		var piece = pieces.get_child(i)
		piece.stage = map_state.pop_back()
		piece.update(0)
	
func reset():
	for piece in pieces.get_children():
		piece.stage = -1
		piece.update(0)
