extends Node2D

signal puzzle_completed(clue_id: String)
signal puzzle_restart

@onready var mario: Player = $Mario

func _ready() -> void:
	mario.castle_entered.connect(puzzle_complete)
	mario.mario_die.connect(restart_puzzle)

func puzzle_complete(): 
	emit_signal("puzzle_completed", "signboard")
	
func restart_puzzle(): 
	emit_signal("puzzle_restart")
