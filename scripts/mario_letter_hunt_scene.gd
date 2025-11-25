extends Node2D

signal puzzle_completed(clue_id: String)
signal puzzle_restart

@onready var mario: Player = $Mario

func _ready() -> void:
	mario.castle_entered.connect(puzzle_complete)
	mario.mario_die.connect(restart_puzzle)
	if DisplayServer.has_feature(DisplayServer.Feature.FEATURE_TEXT_TO_SPEECH) and len(DisplayServer.tts_get_voices()) > 0:
		DisplayServer.tts_speak("Hurry! Improve your score by making the detective collect all the letters that sound like at", GlobalSettings.default_language, GlobalSettings.master_volume, GlobalSettings.speech_pitch, GlobalSettings.speech_rate, 1)
	ScoreManager.start_puzzle("signboard")

func puzzle_complete():
	ScoreManager.complete_puzzle("signboard")
	emit_signal("puzzle_completed", "signboard")
	
func restart_puzzle(): 
	emit_signal("puzzle_restart")
