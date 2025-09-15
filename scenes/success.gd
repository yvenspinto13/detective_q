extends Node2D

@onready var next_button = $Sprite2D/Next  # adjust path

func _ready():
	if next_button:
		next_button.pressed.connect(_on_next_pressed)

func _on_next_pressed():
	print("Next pressed, going to next question")
	get_tree().change_scene_to_file("res://node_2d.tscn") # or another puzzle
