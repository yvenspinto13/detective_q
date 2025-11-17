extends Area2D

class_name Enemy

const POINTS_LABEL_SCENE = preload("res://scenes/PointsLabel.tscn")

@export var horizontal_speed = 20
@export var vertical_speed = 100
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	position.x -= delta * horizontal_speed
	
	if !ray_cast_2d.is_colliding():
		position.y += delta * vertical_speed

func die():
	horizontal_speed = 0
	vertical_speed = 0
	animated_sprite_2d.play("dead")
	

func die_from_hit():
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)
	
	rotation_degrees = 180
	vertical_speed = 0
	horizontal_speed = 0
	
	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", position + Vector2(0, -25), .2)
	die_tween.chain().tween_property(self, "position", position + Vector2(0, 500), 4)
	
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = self.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)


func _on_area_entered(area):
	if area is Koopa and (area as Koopa).in_a_shell and (area as Koopa).horizontal_speed !=0:
		die_from_hit()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	set_process(true)
