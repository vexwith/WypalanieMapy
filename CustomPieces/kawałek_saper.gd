extends Piece

@onready var bomb = $Sprite2D
@onready var sfx = $SFX
@onready var uzbrojenie = preload("res://Wavs/00ekran.wav")
@onready var explosion = preload("res://Wavs/explosion-91872.mp3")

func _ready():
	super._ready()
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	
	
func _on_piece_clicked(piece):
	if piece == self and stage <= 5:
		bomb.show()
		sfx.stream = uzbrojenie
		sfx.play()
		await sfx.finished
		sfx.stream = explosion
		sfx.play()
		bomb.hide()
		self.stage = 5
		update(0)
