extends Node2D


func _on_back_title_pressed():
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scene/title.tscn")
	

func _on_angelus_pressed():
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scene/puzzle_angelus.tscn")


func _on_zodiac_pressed():
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scene/puzzle_zodiac.tscn")


func _on_auvers_pressed():
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scene/puzzle_auvers.tscn")
