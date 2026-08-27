extends Node2D

const PIECE_COUNT = 25

@onready var piece_scene = preload("res://scene/piece_angelus.tscn")
@onready var piece_textures = [
	preload("res://image/newpuzzle/An/1_1.png"),
	preload("res://image/newpuzzle/An/1_2.png"),
	preload("res://image/newpuzzle/An/1_3.png"),
	preload("res://image/newpuzzle/An/1_4.png"),
	preload("res://image/newpuzzle/An/1_5.png"),
	preload("res://image/newpuzzle/An/2_1.png"),
	preload("res://image/newpuzzle/An/2_2.png"),
	preload("res://image/newpuzzle/An/2_3.png"),
	preload("res://image/newpuzzle/An/2_4.png"),
	preload("res://image/newpuzzle/An/2_5.png"),
	preload("res://image/newpuzzle/An/3_1.png"),
	preload("res://image/newpuzzle/An/3_2.png"),
	preload("res://image/newpuzzle/An/3_3.png"),
	preload("res://image/newpuzzle/An/3_4.png"),
	preload("res://image/newpuzzle/An/3_5.png"),
	preload("res://image/newpuzzle/An/4_1.png"),
	preload("res://image/newpuzzle/An/4_2.png"),
	preload("res://image/newpuzzle/An/4_3.png"),
	preload("res://image/newpuzzle/An/4_4.png"),
	preload("res://image/newpuzzle/An/4_5.png"),
	preload("res://image/newpuzzle/An/5_1.png"),
	preload("res://image/newpuzzle/An/5_2.png"),
	preload("res://image/newpuzzle/An/5_3.png"),
	preload("res://image/newpuzzle/An/5_4.png"),
	preload("res://image/newpuzzle/An/5_5.png"),
]

var start_positions = [
	Vector2(1330,140), Vector2(1610,760), Vector2(1330,350), Vector2(1610,560),
	Vector2(1330,760), Vector2(1610,350), Vector2(1330,560), Vector2(1610,140),
	Vector2(1330,140), Vector2(1610,760), Vector2(1330,350), Vector2(1610,560),
	Vector2(1330,760), Vector2(1610,350), Vector2(1330,560), Vector2(1610,140),
	Vector2(1330,140), Vector2(1610,760), Vector2(1330,350), Vector2(1610,560),
	Vector2(1330,760), Vector2(1610,350), Vector2(1330,560), Vector2(1610,140),
	Vector2(1330,140),
]
var end_positions = [
	Vector2(180,166), Vector2(360,166), Vector2(540,166), Vector2(720,166), Vector2(900,166),
	Vector2(180,316), Vector2(360,316), Vector2(540,316), Vector2(720,316), Vector2(900,316),
	Vector2(180,466), Vector2(360,466), Vector2(540,466), Vector2(720,466), Vector2(900,466),
	Vector2(180,616), Vector2(360,616), Vector2(540,616), Vector2(720,616), Vector2(900,616),
	Vector2(180,766), Vector2(360,766), Vector2(540,766), Vector2(720,766), Vector2(900,766),
]
var puzzle_pieces = []
var elapsed_seconds = 0.0
var timer_running = false
var puzzle_completed = false

@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var completion_popup = $CompletionPopup


func _ready() -> void:
	randomize()
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
