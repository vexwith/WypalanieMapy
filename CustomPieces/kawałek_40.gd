extends Piece

@onready var timer = $Timer

var starting_pos = Vector2(99, 1087)
var ending_pos =  Vector2(302, 800)

func _ready():
	position = starting_pos
	
func _process(delta):
	if position.x > 243:
		affected_pieces = [18]
	elif position.x < 180:
		affected_pieces = []
	else:
		affected_pieces = [1, 2, 4, 5, 6, 7, 8, 9, 10, 11]		
		

func _on_timer_timeout():
	timer.start() #loop
	
	var tween = get_tree().create_tween()
	if position == starting_pos:
		tween.tween_property(self, "position", ending_pos, 2.0).set_ease(Tween.EASE_OUT_IN)
	else:
		tween.tween_property(self, "position", starting_pos, 2.0).set_ease(Tween.EASE_OUT_IN)
