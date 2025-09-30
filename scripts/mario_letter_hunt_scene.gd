extends Node2D

signal puzzle_completed(clue_id: String)

@onready var mario: Player = $Mario

func _ready() -> void:
	mario.castle_entered.connect(puzzle_complete)

func puzzle_complete(): 
	emit_signal("puzzle_completed", "signboard")
