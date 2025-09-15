extends Node2D

@onready var tryagain_button = $Sprite2D/TryAgain  # adjust path

func _ready():
	if tryagain_button:
		tryagain_button.pressed.connect(_on_tryagain_pressed)

func _on_tryagain_pressed():
	print("Try Again pressed, restarting puzzle")
	get_tree().change_scene_to_file("res://scenes/WordBuildScene.tscn")
