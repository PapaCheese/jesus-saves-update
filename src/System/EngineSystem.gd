extends Node

onready var event_bus = $"/root/EventBus"

func _ready() -> void:
	event_bus.connect("quit_game", self, "_on_quit_game")
	event_bus.connect("pause_game", self, "_on_pause_game")
	event_bus.connect("resume_game", self, "_on_resume_game")

func _on_quit_game() -> void:
	get_tree().quit()

func _on_pause_game() -> void:
	get_tree().paused = true

func _on_resume_game() -> void:
	get_tree().paused = false
