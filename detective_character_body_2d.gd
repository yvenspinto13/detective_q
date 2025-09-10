extends CharacterBody2D

@export var speed: float = 200.0
var gate_triggered: bool = false

signal gate_touched

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Input handling
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed

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
					emit_signal("gate_touched")
