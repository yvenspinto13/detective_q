extends Sprite2D

var dragging: bool = false
var drop_target: Control = null  # last drop zone overlapped

signal dropsignal
signal startdrag

func _ready() -> void:
	dropsignal.connect(Callable(get_parent().get_parent(), "_receive_drop"))
	startdrag.connect(Callable(get_parent().get_parent(), "_start_drag"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if get_rect().has_point(to_local(event.position)):
				dragging = true
				print("dragging")
				emit_signal("startdrag")
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			dragging = false
			print("drag off")
			if drop_target:
				print("Dropped into:", drop_target.name)
				# snap center into zone
				global_position = drop_target.global_position + drop_target.size/2
				emit_signal("dropsignal", drop_target)
			else:
				print("Not dropped into any zone")
		
	elif event is InputEventMouseMotion and dragging:
		global_position = event.position
		
	if event is InputEventScreenTouch:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
		else:
			dragging = false
	elif event is InputEventScreenDrag and dragging:
		global_position = event.position

# Called every frame to check overlaps
func _process(delta: float) -> void:
	if dragging:
		drop_target = null
		for zone in get_tree().get_nodes_in_group("drop_zones"):
			var rect = Rect2(zone.global_position, zone.size)
			if rect.has_point(global_position):
				drop_target = zone
				break
