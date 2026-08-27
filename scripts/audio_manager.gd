extends Node

var background_music: AudioStreamMP3 = preload("res://sound/배경음악.MP3")
var click_sound: AudioStreamMP3 = preload("res://sound/클릭.MP3")
var place_sound: AudioStreamMP3 = preload("res://sound/놓기.MP3")
var completion_sound: AudioStreamMP3 = preload("res://sound/박수.MP3")

var music_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var place_player: AudioStreamPlayer
var completion_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	background_music.loop = true
	music_player = _create_player(background_music)
	click_player = _create_player(click_sound)
	place_player = _create_player(place_sound)
	completion_player = _create_player(completion_sound)

	music_player.play()


func _create_player(audio_stream: AudioStream) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = audio_stream
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player


func play_click() -> void:
	click_player.play()


func play_place() -> void:
	# 짧게 드래그했을 때 조각을 집으며 난 클릭음이 놓기음과 겹치지 않게 한다.
	click_player.stop()
	place_player.play()


func play_completion() -> void:
	completion_player.play()
