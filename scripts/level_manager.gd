extends Node

class_name LevelManger

var points = 0
var coins = 0

@export var ui: UI
@export var player: Player

func _ready() -> void:
	player.points_scored.connect(on_points_scored)
	player.castle_entered.connect(ui.on_finish)


func on_points_scored(points_scored: int):
	points += points_scored
	ui.set_score(points)

func on_coin_collected():
	print("coin collected")
	coins += 1
	ui.set_coins(coins)

func on_coin_removed():
	print("coin removed")
	coins -= 1
	ui.set_coins(coins)
