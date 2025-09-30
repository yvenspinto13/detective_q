extends Node2D

@onready var player = $CharacterBody2D
@onready var main_tiles = $TileMap
@onready var puzzle_container = $PuzzleContainer
@onready var tile_layer = $TileMap
@onready var success_label = $SuccessLabel

var puzzle_instance
var puzzles_solved: Dictionary = {
	"gate": false,
	"toy_box": false,
	"tree_house": false,
	"signboard": false,
}
var current_puzzle_tile = -1
var mark_and_update_tile_call
var virtual_joystick: Area2D

func _ready() -> void:
	# Connect the player's gate signal
	player.puzzle_touched.connect(_on_puzzle_touched)
	mark_and_update_tile_call = Callable(tile_layer, "mark_and_update_tile")
	virtual_joystick = get_tree().get_first_node_in_group("virtual_joystick")


func _on_puzzle_touched(puzzle: String, tile_id: int) -> void:
	print("Player touched puzzle...", puzzle)
	current_puzzle_tile = tile_id
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
	virtual_joystick.visible = isVisible
	virtual_joystick.set_process(isVisible)

func _on_puzzle_complete(puzzle: String) -> void:
	print("clue:", puzzle)
	mark_and_update_tile_call.call(puzzle, current_puzzle_tile)
	puzzle_container.remove_child(puzzle_instance)
	_set_main_level_visibility(true)
	player.gate_triggered = false
	mark_solved(puzzle)


func mark_solved(key: String) -> void:
	print("i am called")
	if puzzles_solved.has(key):
		puzzles_solved[key] = true
	for value in puzzles_solved.values():
		print("Value:", value)
		if value == false:
			return
	print("printing victory")
	success_label.text = "Hooray!! Level complete!\nYou found the cat!"
