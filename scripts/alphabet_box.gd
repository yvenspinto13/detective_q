extends Block

class_name AlphabetBox

const COIN_SCENE = preload("res://scenes/Coin.tscn")

@onready var label: Label = $Sprite2D/Label


@export var alphabet: String = ""

var is_empty = false

func _ready() -> void:
	label.text = alphabet
	
func bump(player_mode: Player.PlayerMode):
	if is_empty:
		return
	
	super.bump(player_mode)
	is_empty = true
	
	if label.text == 'p':
		label.text=""
		spawn_coin()
	else:
		label.text = "X"
		get_tree().get_first_node_in_group("level_manager").on_coin_removed()


func spawn_coin():
	var coin = COIN_SCENE.instantiate()
	coin.global_position = global_position + Vector2(0, -16)
	get_tree().root.add_child(coin)
	get_tree().get_first_node_in_group("level_manager").on_coin_collected()
