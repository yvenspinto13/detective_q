extends Node2D

@onready var particles: CPUParticles2D = $Particles

var shapes = [
	preload("res://assets/shapes/circle.png"),
	preload("res://assets/shapes/square.png"),
	preload("res://assets/shapes/triangle.png"),
	preload("res://assets/shapes/star.png")
]

var colors = [
	Color(1, 0.2, 0.2),
	Color(0.2, 1, 0.2),
	Color(0.2, 0.2, 1),
	Color(1, 1, 0.2),
	Color(0.8, 0.2, 1)
]

func play_confetti():
	# Random texture
	particles.texture = shapes[randi() % shapes.size()]

	# Random color gradient
	var gradient = Gradient.new()
	for c in colors:
		gradient.add_point(randf(), c)
	var tex = GradientTexture2D.new()
	tex.gradient = gradient
	particles.color_ramp = tex

	# Reset and emit
	particles.emitting = true
	particles.restart()
