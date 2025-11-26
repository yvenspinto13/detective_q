extends CanvasLayer

@onready var overlay_panel: ColorRect = $OverlayPanel
@onready var results_container: VBoxContainer = $OverlayPanel/PanelContainer/MarginContainer/ResultsContainer
@onready var stars_container: HBoxContainer = $OverlayPanel/PanelContainer/MarginContainer/ResultsContainer/StarsContainer
@onready var score_label: Label = $OverlayPanel/PanelContainer/MarginContainer/ResultsContainer/ScoreLabel
@onready var grade_label: Label = $OverlayPanel/PanelContainer/MarginContainer/ResultsContainer/GradeLabel
@onready var time_label: Label = $OverlayPanel/PanelContainer/MarginContainer/ResultsContainer/TimeLabel
@onready var message_label: Label = $OverlayPanel/PanelContainer/MarginContainer/ResultsContainer/MessageLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Star textures (you'll need to create/import these)
var star_full = preload("res://assets/full-star.png") # Gold star
var star_empty = preload("res://assets/half-star.png") # Gray/empty star

func _ready():
	# Start hidden
	visible = false
	
	# Connect button
	#if continue_button:
		#continue_button.pressed.connect(_on_continue_pressed)

# Call this to show the overlay
func show_results():
	visible = true
	var report = ScoreManager.get_summary_report()
	
	# Determine stars based on grade
	var star_count = get_star_count(report.grade)
	display_stars(star_count)
	
	# Display score with fun formatting
	score_label.text = "Score: %d" % report.total_score
	grade_label.text = "Grade: %s" % report.grade
	time_label.text = "Time: %s" % ScoreManager.format_time(report.total_time)
	
	# Fun message based on performance
	message_label.text = get_message(report.grade, report.total_wrong_attempts)
	
	# Play entrance animation
	if animation_player and animation_player.has_animation("popup"):
		animation_player.play("popup")
	else:
		# Simple fade in if no animation
		#self.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)

# Get star count based on grade
func get_star_count(grade: String) -> int:
	match grade:
		"S", "A+":
			return 3
		"A", "B":
			return 2
		"C", "D":
			return 1
		_:
			return 0

# Display stars with animation
func display_stars(count: int):
	# Clear existing stars
	for child in stars_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	# Create 3 stars total
	for i in range(3):
		var star = TextureRect.new()
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(64, 64)
		
		# Use full or empty star
		if i < count:
			star.texture = star_full
		else:
			star.texture = star_empty
		
		stars_container.add_child(star)
		
		# Animate star appearance
		if i < count:
			star.scale = Vector2.ZERO
			star.rotation = -PI
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			await get_tree().create_timer(0.2 * (i + 1)).timeout
			tween.tween_property(star, "scale", Vector2.ONE, 0.4)
			tween.parallel().tween_property(star, "rotation", 0.0, 0.4)

# Get encouraging message
func get_message(grade: String, wrong_attempts: int) -> String:
	if grade == "S" or grade == "A+":
		return "AMAZING DETECTIVE!"
	elif grade == "A":
		return "GREAT JOB!"
	elif grade == "B":
		return "WELL DONE!"
	elif grade == "C":
		return "GOOD TRY!"
	else:
		return "KEEP PRACTICING!"

func _on_continue_pressed():
	# Fade out and close
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()
