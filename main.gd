extends Node2D

@onready var player = $CharacterBody2D
#@onready var puzzle_container = $PuzzleContainer

func _ready() -> void:
	# Connect the player's gate signal
	player.gate_touched.connect(_on_gate_touched)

func _on_gate_touched() -> void:
	print("Player reached the gate! Opening puzzle...")
	
	#var puzzle_scene: PackedScene = preload("res://scenes/WordBuildScene.tscn")
	#var puzzle_instance = puzzle_scene.instantiate()
	#
	#puzzle_container.add_child(puzzle_instance)
	#puzzle_container.visible = true
	#
	## Optional: stop player movement while puzzle is active
	player.set_process(false)
