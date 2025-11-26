extends Node

# Puzzle data structure
class PuzzleScore:
	var puzzle_name: String
	var time_taken: float = 0.0
	var wrong_attempts: Array = [] # Array of {attempt: String, timestamp: float}
	var hints_used: int = 0
	var completed: bool = false
	var perfect_score: bool = false # No wrong attempts
	var speed_bonus: bool = false # Completed quickly
	
	func _init(name: String):
		puzzle_name = name

# Game state
var puzzle_scores: Dictionary = {}
var total_wrong_attempts: int = 0
var game_start_time: float = 0.0
var game_end_time: float = 0.0
var current_puzzle: String = ""
var puzzle_start_time: float = 0.0

# Scoring constants
const PERFECT_PUZZLE_BONUS: int = 100
const SPEED_BONUS: int = 50
const COMPLETION_BONUS: int = 200
const TIME_THRESHOLD_FAST: float = 30.0 # seconds for speed bonus

# Puzzle names
const PUZZLE_NAMES = [
	"gate",
	"toy_box",
	"tree_house",
	"signboard"
]

func _ready():
	# Initialize puzzle scores
	for puzzle_name in PUZZLE_NAMES:
		puzzle_scores[puzzle_name] = PuzzleScore.new(puzzle_name)

# Call this when the game starts
func start_game():
	game_start_time = Time.get_ticks_msec() / 1000.0
	reset_scores()

# Call this when a puzzle starts
func start_puzzle(puzzle_name: String):
	if puzzle_name in puzzle_scores:
		current_puzzle = puzzle_name
		puzzle_start_time = Time.get_ticks_msec() / 1000.0
		print("Started puzzle: ", puzzle_name)

# Call this when a puzzle is completed
func complete_puzzle(puzzle_name: String):
	print("Completed puzzle: ", puzzle_name)
	if puzzle_name in puzzle_scores:
		var puzzle = puzzle_scores[puzzle_name]
		puzzle.completed = true
		puzzle.time_taken = (Time.get_ticks_msec() / 1000.0) - puzzle_start_time
		
		# Check for perfect score (no wrong attempts)
		if puzzle.wrong_attempts.size() == 0:
			puzzle.perfect_score = true
		
		# Check for speed bonus
		if puzzle.time_taken <= TIME_THRESHOLD_FAST:
			puzzle.speed_bonus = true
		
		print("Completed puzzle: ", puzzle_name, " in ", puzzle.time_taken, " seconds")
		current_puzzle = ""

# Call this when player makes a wrong attempt
func record_wrong_attempt(puzzle_name: String, attempt_description: String):
	if puzzle_name in puzzle_scores:
		var puzzle = puzzle_scores[puzzle_name]
		var timestamp = (Time.get_ticks_msec() / 1000.0) - puzzle_start_time
		puzzle.wrong_attempts.append({
			"attempt": attempt_description,
			"timestamp": timestamp
		})
		total_wrong_attempts += 1
		print("Wrong attempt in ", puzzle_name, ": ", attempt_description)

# Call this when player uses a hint
func record_hint_used(puzzle_name: String):
	if puzzle_name in puzzle_scores:
		puzzle_scores[puzzle_name].hints_used += 1

# Calculate total score
func calculate_total_score() -> int:
	var total_score = 0
	
	for puzzle_name in PUZZLE_NAMES:
		var puzzle = puzzle_scores[puzzle_name]
		if puzzle.completed:
			# Base score for completion
			total_score += 100
			
			# Perfect puzzle bonus
			if puzzle.perfect_score:
				total_score += PERFECT_PUZZLE_BONUS
			
			# Speed bonus
			if puzzle.speed_bonus:
				total_score += SPEED_BONUS
			
			# Time-based scoring (faster = more points, max 50 points)
			var time_score = max(0, 50 - int(puzzle.time_taken / 2))
			total_score += time_score
			
			# Deduct points for hints
			total_score -= puzzle.hints_used * 10
	
	# Check if all puzzles completed
	if all_puzzles_completed():
		total_score += COMPLETION_BONUS
		game_end_time = Time.get_ticks_msec() / 1000.0
	
	return max(0, total_score) # Never negative

# Get grade based on score
func get_grade(score: int) -> String:
	if score >= 900:
		return "S"
	elif score >= 800:
		return "A+"
	elif score >= 700:
		return "A"
	elif score >= 600:
		return "B"
	elif score >= 500:
		return "C"
	else:
		return "D"

# Check if all puzzles are completed
func all_puzzles_completed() -> bool:
	for puzzle_name in PUZZLE_NAMES:
		if not puzzle_scores[puzzle_name].completed:
			return false
	return true

# Get total game time
func get_total_game_time() -> float:
	if game_end_time > 0:
		return game_end_time - game_start_time
	return (Time.get_ticks_msec() / 1000.0) - game_start_time

# Generate summary report
func get_summary_report() -> Dictionary:
	var score = calculate_total_score()
	return {
		"total_score": score,
		"grade": get_grade(score),
		"total_time": get_total_game_time(),
		"total_wrong_attempts": total_wrong_attempts,
		"puzzles": puzzle_scores
	}

# Format time as MM:SS
func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60)
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

# Reset all scores
func reset_scores():
	for puzzle_name in PUZZLE_NAMES:
		puzzle_scores[puzzle_name] = PuzzleScore.new(puzzle_name)
	total_wrong_attempts = 0
	game_start_time = 0.0
	game_end_time = 0.0
	current_puzzle = ""
