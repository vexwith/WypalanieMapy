extends Control


@onready var pieces = $Pieces

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
	Globals.ignore_clicks = false
	get_parent().find_child("Ognik").przedmioty["lapa"] = false
	get_parent().find_child("Ognik").przedmioty["ognik"] = true
	
	reset()
		
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property($Text/Label, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label2, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Text/Label3, "modulate", Color.WHITE, 2.0)
	tween.tween_property($Label, "modulate", Color.WHITE, 2.0)

func _on_piece_clicked(clicked_piece):
	var win_condition = true
	for piece in pieces.get_children():
		if piece.stage != 3 and piece.stage != 4:
			win_condition = false
			
	if win_condition:
		get_parent().sfx.stream = get_parent().win
		get_parent().sfx.play()
		await get_parent().sfx.finished
		var tutorial = get_parent().tutorial_three.instantiate()
		get_parent().get_child(1).add_sibling(tutorial)
		queue_free()
		
func reset():
	for i in range(6):
		var piece = pieces.get_child(i)
		piece.stage = i - 1
		piece.update(0)
