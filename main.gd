extends Node2D

@onready var player = $CharacterBody2D
@onready var main_tiles = $TileMap
@onready var puzzle_container = $PuzzleContainer
@onready var tile_layer = $TileMap
@onready var success_label = $SuccessLabel
@onready var color_rect: ColorRect = $ColorRect

var results_overlay_scene = preload("res://scenes/ResultsScene.tscn")

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
var clue_count = 0

func _ready() -> void:
	if DisplayServer.has_feature(DisplayServer.Feature.FEATURE_TEXT_TO_SPEECH):
		print("TTS feature available. Available voices:")
		var voices = DisplayServer.tts_get_voices()
		print("voices available", len(voices))
		#for voice in voices:
			#print("Name: %s, Language: %s" % [voice.name, voice.language])
	# Connect the player's gate signal
	player.puzzle_touched.connect(_on_puzzle_touched)
	mark_and_update_tile_call = Callable(tile_layer, "mark_and_update_tile")
	virtual_joystick = get_tree().get_first_node_in_group("virtual_joystick")
	print("speka instructions")
	success_label.text = "Clues: 0/4"
	await get_tree().create_timer(1.0).timeout
	DisplayServer.tts_speak("Welcome to detectiveQ! Follow the brown path to solve puzzles and gain valuable clues. Use the joystick on the bottom left of your screen to move the detective.", GlobalSettings.default_language, GlobalSettings.master_volume, GlobalSettings.speech_pitch, GlobalSettings.speech_rate)
	ScoreManager.start_game()
	


func _on_puzzle_restart(puzzle: String, tile_id: int) -> void:
	if puzzle_instance:
		puzzle_instance.queue_free()
		puzzle_instance = null
	print("==restart puzzle", puzzle)
	var puzzle_scene: PackedScene = load("res://scenes/%s.tscn" % puzzle)
	Input.flush_buffered_events()
	puzzle_instance = puzzle_scene.instantiate()	
	puzzle_instance.puzzle_completed.connect(_on_puzzle_complete)
	puzzle_instance.puzzle_restart.connect(_on_puzzle_restart.bind(puzzle, tile_id))
	puzzle_container.add_child(puzzle_instance)
	

func _on_puzzle_touched(puzzle: String, tile_id: int) -> void:
	print("Player touched puzzle...", puzzle)
	current_puzzle_tile = tile_id
	## Optional: stop player movement while puzzle is active
	player.set_process(false)
	var puzzle_scene: PackedScene = load("res://scenes/%s.tscn" % puzzle)
	puzzle_instance = puzzle_scene.instantiate()	
	puzzle_instance.puzzle_completed.connect(_on_puzzle_complete)
	puzzle_instance.puzzle_restart.connect(_on_puzzle_restart.bind(puzzle, tile_id))
	
	puzzle_container.add_child(puzzle_instance)
	_set_main_level_visibility(false)
	puzzle_container.visible = true


func _set_main_level_visibility(isVisible: bool) -> void:
	main_tiles.visible = isVisible
	player.visible = isVisible
	virtual_joystick.visible = isVisible
	virtual_joystick.set_process(isVisible)
	success_label.visible = isVisible
	color_rect.visible = isVisible

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
		clue_count += 1
		success_label.text = "Clues: %d/4" %clue_count
	for value in puzzles_solved.values():
		print("Value:", value)
		if value == false:
			return
	print("printing victory")
	var report = ScoreManager.get_summary_report()
	print("report", report)
	success_label.text = "Hooray!! Level complete!\nYou found the cat!"
	var overlay = results_overlay_scene.instantiate()
	add_child(overlay)
	overlay.show_results()
