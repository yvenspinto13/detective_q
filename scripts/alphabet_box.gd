extends Block

class_name AlphabetBox

const COIN_SCENE = preload("res://scenes/Coin.tscn")

@onready var label: Label = $Sprite2D/Label
@onready var audio_stream_player: AudioStreamPlayer = $"../../../AudioStreamPlayer"

@export var alphabet: String = ""

var is_empty = false
var tts_enabled = false

func _ready() -> void:
	label.text = alphabet
	# Brendan Heberlein, CC BY-SA 4.0 <https://creativecommons.org/licenses/by-sa/4.0>, via Wikimedia Commons
	audio_stream_player.stream = load("res://audio/æ_cat.ogg")
	
func bump(player_mode: Player.PlayerMode):
	if is_empty:
		return
	
	super.bump(player_mode)
	is_empty = true
	
	if label.text == 'at':
		label.text=""
		spawn_coin()
		audio_stream_player.play()
	else:
		label.text = "X"
		ScoreManager.record_wrong_attempt("signboard","Wrong alphabet chosen")
		get_tree().get_first_node_in_group("level_manager").on_coin_removed()


func spawn_coin():
	var coin = COIN_SCENE.instantiate()
	coin.global_position = global_position + Vector2(0, -16)
	get_tree().root.add_child(coin)
	get_tree().get_first_node_in_group("level_manager").on_coin_collected()
