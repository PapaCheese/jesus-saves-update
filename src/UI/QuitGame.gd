extends Panel

onready var event_bus = $"/root/EventBus"

func _ready() -> void:
	event_bus.connect("toggle_main_menu", self, "_on_toggle_main_menu")

func _on_toggle_main_menu() -> void:
	if !visible:
#		$YesButton.grab_focus()
		event_bus.emit_signal("pause_game")
	else:
		event_bus.emit_signal("resume_game")
	visible = !visible

func _on_YesButton_button_up() -> void:
	event_bus.emit_signal("quit_game")

func _on_MusicButton_toggled(button_pressed) -> void:
	get_node("/root/MainScene/BGM").playing = button_pressed

func _on_OptionsButton_pressed():
	MenuEvent.Options = true

func _on_ResumeButton_button_up():
	visible = false
	get_tree().paused = false
