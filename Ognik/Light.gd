extends PointLight2D

@export var noise: NoiseTexture2D
var timer := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta

	var sampled_noise = noise.noise.get_noise_1d(timer)
	sampled_noise = absf(sampled_noise)
#	print(sampled_noise)
	energy = 0.5 + sampled_noise * 2
