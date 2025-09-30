extends CanvasLayer

class_name UI

@onready var center_container: CenterContainer = $MarginContainer/CenterContainer

@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var points_label: Label = $MarginContainer/HBoxContainer/PointsLabel


func set_score(points: int):
	score_label.text = "SCORE: %d" % points
	

func set_coins(coins: int):
	points_label.text = "COINS: %d" % coins
	

func on_finish():
	center_container.visible = true
