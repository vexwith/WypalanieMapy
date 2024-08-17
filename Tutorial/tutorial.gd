extends Control

@onready var tutorial_two = preload("res://Tutorial/tutorial_two.tscn")
@onready var tutorial_three = preload("res://Tutorial/tutorial_three.tscn")
@onready var tutorial_four = preload("res://Tutorial/tutorial_four.tscn")

@onready var bgm = $BGM
@onready var sfx = $SFX
@onready var ojoj = preload("res://Wavs/6dziura.wav")
@onready var win = preload("res://Wavs/win.wav")

func _ready():
	SignalBus.connect("piece_clicked", _on_piece_clicked)
	bgm.play()

func _on_reset_pressed():
	get_child(1).reset()

func _on_bgm_finished():
	bgm.play()

func _on_piece_clicked(clicked_piece):
	if clicked_piece.stage == 5 or clicked_piece.stage == 6:
		sfx.stream = ojoj
		sfx.play()
