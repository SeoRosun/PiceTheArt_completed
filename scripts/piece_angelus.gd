extends TextureButton

signal movement_started
signal dropped

var drag_offset = Vector2.ZERO
var drag_start_position = Vector2.ZERO
var drag_start_z_index = 1
var is_dragging = false
var target_positions = []
var correct_position = Vector2.ZERO
var movement_signal_sent = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = Color(0.9,0.9,0.9)
	z_index = 1

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		AudioManager.play_click()
		is_dragging = true
		drag_start_position = position
		drag_start_z_index = z_index
		drag_offset = global_position - get_viewport().get_mouse_position()
		z_index = 100
		accept_event()


func _input(event):
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		is_dragging = false
		var nearest_position = _find_nearest_target()
		if nearest_position != null:
			if get_parent().is_end_position_occupied(nearest_position, self):
				set_position(drag_start_position)
				z_index = drag_start_z_index
			else:
				set_position(nearest_position)
				z_index = 0
				AudioManager.play_place()
		else:
			z_index = 1
		dropped.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if is_dragging:
		var new_position = get_viewport().get_mouse_position() + drag_offset
		if not movement_signal_sent and new_position.distance_to(position) > 0.1:
			movement_signal_sent = true
			movement_started.emit()
		set_position(new_position)
	if self.get_position().x <= 0:
		self._set_position(Vector2(0,self.get_position().y))
	if self.get_position().x >= 1720:
		self._set_position(Vector2(1720,self.get_position().y))
	if self.get_position().y <= 0:
		self._set_position(Vector2(self.get_position().x,0))
	if self.get_position().y >= 890:
		self._set_position(Vector2(self.get_position().x,890))


func _find_nearest_target():
	var nearest_position = null
	var nearest_distance = 35.0

	for target_position in target_positions:
		var target_distance = global_position.distance_to(target_position)
		if target_distance < nearest_distance:
			nearest_distance = target_distance
			nearest_position = target_position

	return nearest_position
		
