extends Piece

@onready var timer = $Timer
@onready var lapa = $Lapa

var starting_pos = Vector2(99, 1087)
var ending_pos =  Vector2(302, 800)

var change_affected = true

var game_time = 0.0
var delay_time = 0.0
var DELAY_RATE = 0.2

func _ready():
#	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
	position = starting_pos
	
func _process(delta):
	game_time += delta
	if game_time - delay_time >= DELAY_RATE:
		delay_time = game_time
		clear_affected()
		if position.x > 243:
			affected_pieces = [18, 66]
		elif position.x < 180:
			affected_pieces = [67, 71]
		else:
			affected_pieces = [66, 67, 71]
		update_affected()

func update(damage):
	super.update(damage)
	if not Globals.lapa_gained and stage >= 5:
		lapa.show()
		
func clear_affected():
	if not affected_pieces.is_empty():
		for index in affected_pieces:
			get_parent().get_child(index).affected_pieces.erase(get_index())

func _on_timer_timeout():
	timer.start() #loop
	
	var tween = get_tree().create_tween()
	if position == starting_pos:
		tween.tween_property(self, "position", ending_pos, 2.0).set_ease(Tween.EASE_OUT_IN)
	else:
		tween.tween_property(self, "position", starting_pos, 2.0).set_ease(Tween.EASE_OUT_IN)
	

func _on_lapa_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(lapa, "global_position", Vector2(152, 42), 1.0).set_ease(Tween.EASE_OUT)
	await tween.finished
	lapa.hide()
	Globals.lapa_gained = true
	owner.get_parent().lapa_button.show()
