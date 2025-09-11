extends Node2D

@onready var player = $CharacterBody2D
@onready var main_tiles = $TileMap
@onready var puzzle_container = $PuzzleContainer

var puzzle_instance

func _ready() -> void:
	# Connect the player's gate signal
	player.puzzle_touched.connect(_on_puzzle_touched)

func _on_puzzle_touched(puzzle: String) -> void:
	print("Player touched puzzle...", puzzle)
	
	## Optional: stop player movement while puzzle is active
	player.set_process(false)
	var puzzle_scene: PackedScene = load("res://scenes/%s.tscn" % puzzle)
	puzzle_instance = puzzle_scene.instantiate()
	puzzle_instance.puzzle_completed.connect(_on_puzzle_complete)
	
	puzzle_container.add_child(puzzle_instance)
	_set_main_level_visibility(false)
	puzzle_container.visible = true

func _set_main_level_visibility(isVisible: bool) -> void:
	main_tiles.visible = isVisible
	player.visible = isVisible

func _on_puzzle_complete(clue_id: String) -> void:
	print("clue:", clue_id)
	puzzle_container.remove_child(puzzle_instance)
	_set_main_level_visibility(true)
