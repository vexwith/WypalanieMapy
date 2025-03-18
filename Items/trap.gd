extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var mouse = $mouse

#var temp_mouse_pos : Vector2

func _ready():
	SignalBus.connect("mouse_freed", _on_mouse_freed)

func _on_mouse_entered():

	
	if owner.get_parent().ognik.przedmioty["ognik"]:
		sprite.play("attack")
		await sprite.animation_finished
		sprite.play_backwards("attack")
		
	else:
#		temp_mouse_pos = get_viewport().get_mouse_position()
#		print(temp_mouse_pos)
		sprite.play("attack_mouse")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Globals.trapped = true
		
func _on_mouse_freed():
	if not sprite.is_playing():
		Globals.trapped = false
		sprite.play_backwards("attack_mouse")
		await sprite.animation_finished
		mouse.show()
		var tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(mouse, "global_position", owner.get_parent().camera.global_position + Vector2(27, 28), 0.5).from(global_position)
		await tween.finished
		mouse.hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_area_entered(area):
	if area.is_in_group("return"):
		var gm = owner.get_parent()
		gm.exit.hide()
		sprite.play("attack_return")
		await sprite.animation_finished
		Globals.return_trapped = true
		gm.real_exit.global_position = self.global_position + Vector2(-59.5, -102)
		gm.real_exit.show()
#		gm.exit.hide()
		queue_free()
