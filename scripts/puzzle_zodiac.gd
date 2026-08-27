extends Node2D

const PIECE_COUNT = 35
const START_GRID_COLUMNS = 3
const START_GRID_ROWS = 5
const START_GRID_POSITION_COUNT = START_GRID_COLUMNS * START_GRID_ROWS
const FIRST_START_POSITION = Vector2(1300, 120)
const START_GRID_SPACING = Vector2(185, 175)

@onready var piece_scene = preload("res://scene/piece_zodiac.tscn")
@onready var piece_textures = [
	preload("res://image/newpuzzle/Zo/1_1.png"),
	preload("res://image/newpuzzle/Zo/1_2.png"),
	preload("res://image/newpuzzle/Zo/1_3.png"),
	preload("res://image/newpuzzle/Zo/1_4.png"),
	preload("res://image/newpuzzle/Zo/1_5.png"),
	preload("res://image/newpuzzle/Zo/2_1.png"),
	preload("res://image/newpuzzle/Zo/2_2.png"),
	preload("res://image/newpuzzle/Zo/2_3.png"),
	preload("res://image/newpuzzle/Zo/2_4.png"),
	preload("res://image/newpuzzle/Zo/2_5.png"),
	preload("res://image/newpuzzle/Zo/3_1.png"),
	preload("res://image/newpuzzle/Zo/3_2.png"),
	preload("res://image/newpuzzle/Zo/3_3.png"),
	preload("res://image/newpuzzle/Zo/3_4.png"),
	preload("res://image/newpuzzle/Zo/3_5.png"),
	preload("res://image/newpuzzle/Zo/4_1.png"),
	preload("res://image/newpuzzle/Zo/4_2.png"),
	preload("res://image/newpuzzle/Zo/4_3.png"),
	preload("res://image/newpuzzle/Zo/4_4.png"),
	preload("res://image/newpuzzle/Zo/4_5.png"),
	preload("res://image/newpuzzle/Zo/5_1.png"),
	preload("res://image/newpuzzle/Zo/5_2.png"),
	preload("res://image/newpuzzle/Zo/5_3.png"),
	preload("res://image/newpuzzle/Zo/5_4.png"),
	preload("res://image/newpuzzle/Zo/5_5.png"),
	preload("res://image/newpuzzle/Zo/6_1.png"),
	preload("res://image/newpuzzle/Zo/6_2.png"),
	preload("res://image/newpuzzle/Zo/6_3.png"),
	preload("res://image/newpuzzle/Zo/6_4.png"),
	preload("res://image/newpuzzle/Zo/6_5.png"),
	preload("res://image/newpuzzle/Zo/7_1.png"),
	preload("res://image/newpuzzle/Zo/7_2.png"),
	preload("res://image/newpuzzle/Zo/7_3.png"),
	preload("res://image/newpuzzle/Zo/7_4.png"),
	preload("res://image/newpuzzle/Zo/7_5.png"),
]

var start_positions = []
var end_positions = [
	Vector2(290,95), Vector2(420,95), Vector2(550,95), Vector2(680,95), Vector2(810,95),
	Vector2(290,220), Vector2(420,220), Vector2(550,220), Vector2(680,220), Vector2(810,220),
	Vector2(290,345), Vector2(420,345), Vector2(550,345), Vector2(680,345), Vector2(810,345),
	Vector2(290,470), Vector2(420,470), Vector2(550,470), Vector2(680,470), Vector2(810,470),
	Vector2(290,595), Vector2(420,595), Vector2(550,595), Vector2(680,595), Vector2(810,595),
	Vector2(290,720), Vector2(420,720), Vector2(550,720), Vector2(680,720), Vector2(810,720),
	Vector2(290,845), Vector2(420,845), Vector2(550,845), Vector2(680,845), Vector2(810,845),
]
var puzzle_pieces = []
var elapsed_seconds = 0.0
var timer_running = false
var puzzle_completed = false

@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var completion_popup = $CompletionPopup


func _ready() -> void:
	randomize()
	_create_start_positions()
	start_positions.shuffle()

	for piece_index in PIECE_COUNT:
		var piece = piece_scene.instantiate()
		add_child(piece)
		piece.set_texture_normal(piece_textures[piece_index])
		piece.set_position(start_positions[piece_index])
		piece.target_positions = end_positions
		piece.correct_position = end_positions[piece_index]
		piece.movement_started.connect(_start_timer)
		piece.dropped.connect(_check_completion)
		puzzle_pieces.append(piece)


func _create_start_positions() -> void:
	for piece_index in PIECE_COUNT:
		var slot_index = piece_index % START_GRID_POSITION_COUNT
		var start_row = slot_index / START_GRID_COLUMNS
		var start_column = slot_index % START_GRID_COLUMNS
		start_positions.append(FIRST_START_POSITION + Vector2(start_column, start_row) * START_GRID_SPACING)


func _process(delta):
	if timer_running:
		elapsed_seconds += delta
		_update_timer_label()

	for piece in puzzle_pieces:
		if _is_near_end_position(piece.position):
			piece.modulate = Color(1,1,1)
		else:
			piece.modulate = Color(0.9,0.9,0.9)


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
