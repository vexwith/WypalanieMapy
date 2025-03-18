extends Piece

@export var mid_pos = Vector2(624.445, 485.556)
@export var high_pos = Vector2(797.222, 398.333)
var low_pos : Vector2

var game_time = 0.0
var MOVE_RATE = 5.0
var move_time = 0.0

func _ready():
	super._ready()
	low_pos = mid_pos + (mid_pos - high_pos)

func _process(delta):
	game_time += delta
	
	if game_time - move_time >= MOVE_RATE:
		move_time = game_time
		
		if position == high_pos:
			move_to_dest(low_pos)
		elif position == low_pos:
			move_to_dest(high_pos)
		else:
			MOVE_RATE = 20.0
			var tween = get_tree().create_tween().bind_node(self)
			tween.tween_property(self, "position", high_pos, 2.0)

func move_to_dest(dest):
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position", mid_pos, 2.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", dest, 2.0).set_ease(Tween.EASE_IN).set_delay(5.0)
	
