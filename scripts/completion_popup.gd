extends CanvasLayer

@onready var completion_overlay: Control = $CompletionOverlay
@onready var completion_time_label: Label = $CompletionOverlay/CompletionTimeLabel
@onready var retry_button: TextureButton = $CompletionOverlay/RetryButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	completion_overlay.hide()


func show_completion(elapsed_seconds: float) -> void:
	completion_time_label.text = "완성 시간  %s" % _format_elapsed_time(elapsed_seconds)
	completion_overlay.show()
	AudioManager.play_completion()
	get_tree().paused = true
	retry_button.grab_focus()


func _format_elapsed_time(elapsed_seconds: float) -> String:
	var minutes = floori(elapsed_seconds / 60.0)
	var seconds = floori(fmod(elapsed_seconds, 60.0))
	var centiseconds = floori(fmod(elapsed_seconds, 1.0) * 100.0)
	return "%02d:%02d.%02d" % [minutes, seconds, centiseconds]


func _on_retry_button_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_select_button_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/select.tscn")


func _exit_tree() -> void:
	get_tree().paused = false
