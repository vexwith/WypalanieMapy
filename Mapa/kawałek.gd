extends Area2D
class_name Piece

@onready var sprite = $AnimatedSprite2D
@onready var rim = $Rim

@export var affected_pieces = []

var stage = -1 #stopień spalenia
var stage_number

var cursor_entered = false
var modulation = 0.7 #0.7
var affected_modulation = Color.ROSY_BROWN #SKY_BLUE 87ceeb

var clickable = true #used in first map outer pieces

func _ready():
	rim.modulate.a = 0.0
	rim.z_index = 1
	
	stage_number = find_child("StageNumber")
	if stage_number != null:
#		stage_number.scale = Vector2(1.0, 1.0)
		stage_number.rotation_degrees -= rotation_degrees
		stage_number.hide()

func _process(delta):
	if stage_number != null:
		stage_number.text = str(min(stage + 1, 6))
	
	if cursor_entered and clickable and not Globals.crawl_mode and Globals.detail_mode:
#		modulate.a = modulation
		if stage_number != null: stage_number.show()
		for i in affected_pieces:
			var piece = get_parent().get_child(i)
			piece.rim.modulate = affected_modulation
			if stage_number != null: piece.stage_number.show()

func _input(event):
	if cursor_entered and clickable and not Globals.ignore_clicks and event.is_action_pressed("LPM"):
		make_move()
				
		SignalBus.emit_signal("piece_clicked", self)
	
#	if cursor_entered and event.is_action_pressed("PPM"): #test
#		undo_move()
				
func make_move():
	move(2, 1)
				
func undo_move():
	move(-2, -1)
				
func move(main, sub):
	update(main) #self update zadaje/dodaje 2 stage
		
	if not affected_pieces.is_empty():
		for piece_index in affected_pieces:
			var piece = get_parent().get_child(piece_index)
			piece.update(sub) #zależne kawałki updatują się o 1
				
func update(damage):
	if stage < 0: #if we start from -1 show sprite
		if sign(damage) == -1: #cant undo more than -1
			return
		sprite.show()
	stage = stage + damage
	if stage < 0: #in case of undoing to -1 hide
		sprite.hide()
	else:
		sprite.play(str(min(stage, 5)))
	
func update_affected(): #used only for first map outer pieces to link with others
	if not affected_pieces.is_empty():
		for index in affected_pieces:
			get_parent().get_child(index).affected_pieces.append(get_index())
			
func clear_affected(): #used when undoing first map outer pieces
	if not affected_pieces.is_empty():
		for index in affected_pieces:
			get_parent().get_child(index).affected_pieces.erase(get_index())

func _on_mouse_entered():
	cursor_entered = true
#	Globals.focused_piece = self
	

func _on_mouse_exited():
	cursor_entered = false
#	Globals.focused_piece = null
#	modulate.a = 1.0
	rim.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if stage_number != null: stage_number.hide()
	for i in affected_pieces:
		var piece = get_parent().get_child(i)
		piece.rim.modulate = Color(1.0, 1.0, 1.0, 0.0)
		if stage_number != null: piece.stage_number.hide()
