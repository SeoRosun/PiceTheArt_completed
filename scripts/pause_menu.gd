extends CanvasLayer

@onready var pause_button: TextureButton = $PauseButton
@onready var pause_overlay: Control = $PauseOverlay
@onready var continue_button: TextureButton = $PauseOverlay/ContinueButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_overlay.hide()


func _on_pause_button_pressed() -> void:
	AudioManager.play_click()
	pause_overlay.show()
	pause_button.hide()
	get_tree().paused = true
	continue_button.grab_focus()


func _on_continue_button_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	pause_overlay.hide()
	pause_button.show()


func _on_quit_button_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/select.tscn")


func _exit_tree() -> void:
	get_tree().paused = false
