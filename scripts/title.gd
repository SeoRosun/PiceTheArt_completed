extends Node2D


func _on_start_pressed():
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scene/select.tscn")


func _on_exit_pressed():
	get_tree().quit()
