extends Node2D

const PIECE_COUNT = 48
const ROW_COUNT = 6
const COLUMN_COUNT = 8
const PIECE_SIZE = Vector2(110, 115)
const FIRST_END_POSITION = Vector2(193, 197)
const START_GRID_COLUMNS = 4
const START_GRID_ROWS = 6
const START_GRID_POSITION_COUNT = START_GRID_COLUMNS * START_GRID_ROWS
const FIRST_START_POSITION = Vector2(1300, 120)
const START_GRID_SPACING = Vector2(150, 150)

@onready var piece_scene = preload("res://scene/piece_auvers.tscn")
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var completion_popup = $CompletionPopup

var start_positions = []
var end_positions = []
var puzzle_pieces = []
var elapsed_seconds = 0.0
var timer_running = false
var puzzle_completed = false


func _ready() -> void:
	randomize()
	_create_piece_positions()
	start_positions.shuffle()

	for piece_index in PIECE_COUNT:
		var row = piece_index / COLUMN_COUNT
		var column = piece_index % COLUMN_COUNT
		var texture_path = "res://image/newpuzzle/Au/%d_%d.png" % [row + 1, column + 1]
		var piece = piece_scene.instantiate()
		add_child(piece)
		piece.set_texture_normal(load(texture_path))
		piece.set_position(start_positions[piece_index])
		piece.target_positions = end_positions
		piece.correct_position = end_positions[piece_index]
		piece.movement_started.connect(_start_timer)
		piece.dropped.connect(_check_completion)
		puzzle_pieces.append(piece)


func _create_piece_positions() -> void:
	for piece_index in PIECE_COUNT:
		var slot_index = piece_index % START_GRID_POSITION_COUNT
		var start_row = slot_index / START_GRID_COLUMNS
		var start_column = slot_index % START_GRID_COLUMNS
		start_positions.append(FIRST_START_POSITION + Vector2(start_column, start_row) * START_GRID_SPACING)

	for row in ROW_COUNT:
		for column in COLUMN_COUNT:
			end_positions.append(FIRST_END_POSITION + Vector2(column, row) * PIECE_SIZE)


func _process(delta) -> void:
	if timer_running:
		elapsed_seconds += delta
		_update_timer_label()

	for piece in puzzle_pieces:
		if _is_near_end_position(piece.position):
			piece.modulate = Color(1, 1, 1)
		else:
			piece.modulate = Color(0.9, 0.9, 0.9)


func _is_near_end_position(current_position: Vector2) -> bool:
	for end_position in end_positions:
		if current_position.distance_to(end_position) < 40:
			return true
	return false


func is_end_position_occupied(end_position: Vector2, ignored_piece) -> bool:
	for piece in puzzle_pieces:
		if piece != ignored_piece and piece.position.distance_to(end_position) < 1.0:
			return true
	return false


func _start_timer() -> void:
	if not timer_running and not puzzle_completed:
		timer_running = true


func _check_completion() -> void:
	if puzzle_completed:
		return

	for piece in puzzle_pieces:
		if piece.position.distance_to(piece.correct_position) > 1.0:
			return

	puzzle_completed = true
	timer_running = false
	_update_timer_label()
	completion_popup.show_completion(elapsed_seconds)


func _update_timer_label() -> void:
	var minutes = floori(elapsed_seconds / 60.0)
	var seconds = floori(fmod(elapsed_seconds, 60.0))
	var centiseconds = floori(fmod(elapsed_seconds, 1.0) * 100.0)
	timer_label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]
