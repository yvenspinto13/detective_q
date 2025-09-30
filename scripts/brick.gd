extends Block

class_name Brick


func bump(player_mode: Player.PlayerMode):
	if player_mode == Player.PlayerMode.SMALL:
		super.bump(player_mode)
