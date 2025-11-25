extends CharacterBody2D

class_name  Player

signal points_scored(points: int)
signal castle_entered
signal mario_die


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	SMALL,
	BIG,
	SHOOTING
}

# on ready
const POINTS_LABEL_SCENE = preload("res://scenes/PointsLabel.tscn")
const BIG_MARIO_COLLISION_SHAPE = preload("res://resources/collision_shapes/big_mario_collision_shape.tres")
const SMALL_MARIO_COLLISION_SHAPE = preload("res://resources/collision_shapes/small_mario_collision_shape.tres")

# references
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape: CollisionShape2D = $Area2D/AreaCollisionShape
@onready var body_collision_shape: CollisionShape2D = $BodyCollisionShape
@onready var slide_down_finished_position: Marker2D = $"../slide_down_finished_position"
@onready var land_down_marker: Marker2D = $"../LandDownMarker"


@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 200.0
@export var jump_velocity = -350
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stomp_y_velocity = -150
@export_group("")

@export_group("Camera sync")
@export var camera_sync: Camera2D
@export var should_camera_sync: bool = true
@export_group("")

@export var castle_path: PathFollow2D

var player_mode = PlayerMode.SMALL

# state flags

var is_dead = false
var is_on_path = false

func _ready():
	if SceneData.return_point != null && SceneData.return_point != Vector2.ZERO:
		global_position = SceneData.return_point

func _physics_process(delta: float) -> void:
	
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# handles jumps
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *=0.5
	
	# handle axis movement
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = lerpf(velocity.x, speed* direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed*delta)
	
	animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	
	var collision = get_last_slide_collision()
	if collision != null:
		handle_movement_collision(collision)
	move_and_slide()

func _process(delta):
	if global_position.x > camera_sync.global_position.x && should_camera_sync:
		camera_sync.global_position.x = global_position.x
	
	if is_on_path:
		castle_path.progress += delta * speed / 2
		if castle_path.progress_ratio > 0.97:
			is_on_path = false
			land_down()

func handle_movement_collision(collision: KinematicCollision2D):
	if collision.get_collider() is Block:
		var collision_angle = rad_to_deg(collision.get_angle())
		if round(collision_angle) == 180:
			(collision.get_collider() as Block).bump(player_mode)


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("handle collision")
	if area is Enemy:
		print("Enemy collision")
		handle_enemy_collision(area)
	if area is Shroom:
		#print("handle scroom")
		handle_shroom_collision(area)
		area.queue_free()

func handle_enemy_collision(enemy: Enemy):
	if enemy == null || is_dead:
		return
	if is_instance_of(enemy, Koopa) and (enemy as Koopa).in_a_shell:
		(enemy as Koopa).on_stomp(global_position)
		spawn_points_label(enemy)
	else:
		var collision_angle = rad_to_deg(position.angle_to_point(enemy.position))
		if collision_angle > min_stomp_degree and collision_angle < max_stomp_degree:
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else:
			die()
		

func handle_shroom_collision(area: Node2D):
	if player_mode == PlayerMode.SMALL:
		set_physics_process(false)
		animated_sprite_2d.play("small_to_big")
		set_collision_shapes(false)
		#player_mode

func spawn_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

func on_enemy_stomped():
	velocity.y = stomp_y_velocity

func die():
	if player_mode == PlayerMode.SMALL:
		is_dead = true
		animated_sprite_2d.play("death")
		set_collision_layer_value(1, false)
		set_physics_process(false)
		
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -48), .5)
		await death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1).finished
		Input.action_release("left")
		Input.action_release("right")
		Input.action_release("jump")
		mario_die.emit()
		#death_tween.tween_callback(func (): get_tree().reload_current_scene())
		#death_tween.tween_callback(func (): get_tree().change_scene_to_file("res://scenes/MarioLetterHuntScene.tscn"))
		
	else:
		print("Big to small")
		big_to_small()

func set_collision_shapes(is_small: bool):
	var collision_shape = SMALL_MARIO_COLLISION_SHAPE if is_small else BIG_MARIO_COLLISION_SHAPE
	area_collision_shape.set_deferred("shape", collision_shape)
	body_collision_shape.set_deferred("shape", collision_shape)
	

func big_to_small():
	set_collision_layer_value(1, false)
	set_physics_process(false)
	var animation_frame = "small_to_big" if player_mode == PlayerMode.BIG else "small_to_shhoting"
	animated_sprite_2d.play(animation_frame, 1.0, true)
	set_collision_shapes(true)


func on_pole_hit():
	set_physics_process(false)
	velocity = Vector2.ZERO
	if is_on_path:
		return
	
	animated_sprite_2d.on_pole(player_mode)
	
	var slide_down_tween = get_tree().create_tween()
	var slide_down_position = slide_down_finished_position.position
	slide_down_tween.tween_property(self, "position", slide_down_position, 2)
	slide_down_tween.tween_callback(slide_down_finished)

func slide_down_finished():
	var animation_prefix = Player.PlayerMode.keys()[player_mode].to_snake_case()
	is_on_path = true
	print("slide down finishged: %s" % animation_prefix)
	animated_sprite_2d.play("%s_jump" % animation_prefix)
	reparent(castle_path)

func land_down():
	reparent(get_tree().root.get_node("main"))
	print("land down %d" % land_down_marker.position.y )
	print("position %d" % position.y)
	var distance_to_marker = (land_down_marker.position - position).y
	var land_tween = get_tree().create_tween()
	print("disyance to marker %d" % distance_to_marker)
	
	land_tween.tween_property(self, "position", position + Vector2(0, 23), .5)
	land_tween.tween_callback(go_to_castle)

func go_to_castle():
	print("GO TO CASTLE")
	var animation_prefix = Player.PlayerMode.keys()[player_mode].to_snake_case()
	animated_sprite_2d.play("%s_run" % animation_prefix)
	print("going to castle: %s" % animation_prefix)
	var run_to_castle_tween = get_tree().create_tween()
	run_to_castle_tween.tween_property(self, "position", position + Vector2(75, 0), .5)
	run_to_castle_tween.tween_callback(finish)

func finish():
	set_physics_process(false)
	queue_free()
	print("emit castle")
	castle_entered.emit()


func get_half_sprite_size():
	return 8 if player_mode == PlayerMode.SMALL else 16
