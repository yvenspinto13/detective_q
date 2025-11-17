extends Area2D


class_name FalldownArea

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
