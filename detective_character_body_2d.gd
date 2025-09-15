extends CharacterBody2D

@export var speed: float = 140.0
@export var gate_triggered: bool = false
var virtual_joystick: Area2D

signal puzzle_touched

func _ready():
	# Find the virtual joystick node in the scene tree
	virtual_joystick = get_tree().get_first_node_in_group("virtual_joystick")
	print("found virtual joystick",virtual_joystick)

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Input handling
	#if Input.is_action_pressed("ui_right"):
		#direction.x += 1
	#if Input.is_action_pressed("ui_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("ui_down"):
		#direction.y += 1
	#if Input.is_action_pressed("ui_up"):
		#direction.y -= 1
		
	 # Get the direction from the virtual joystick
	if virtual_joystick:
		direction = virtual_joystick.get_move_direction()
	
	# Update velocity based on the joystick direction
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	#direction = direction.normalized()
	#velocity = direction * speed
	
	if velocity != Vector2.ZERO:
		var collision = move_and_collide(velocity * delta)
		if collision and not gate_triggered:
			var collider = collision.get_collider()
			print("received collision")
			if collider is TileMap:
				var tilemap := collider as TileMap
				var tile_pos_x = tilemap.local_to_map(collision.get_position())
				var tile_id_x = tilemap.get_cell_source_id(1, tile_pos_x)
				# Loop through layers (skip grass/ground layer 0)
				print("count", tile_id_x)
				if tile_id_x == 10:
					print("Gate")
					gate_triggered = true
					emit_signal("puzzle_touched", "SoundMatchScene", tile_id_x)
				elif tile_id_x == 2:
					print("toy box")
					gate_triggered = true
					emit_signal("puzzle_touched", "RhymePuzzleScene", tile_id_x)
				elif tile_id_x == 3:
					print("tree house")
					gate_triggered = true
					emit_signal("puzzle_touched", "WordBuildScene", tile_id_x)
				elif  tile_id_x == 1:
					print("Sign board")
					gate_triggered = true
					emit_signal("puzzle_touched", "LetterHuntScene", tile_id_x)
