extends Node

onready var event_bus = $"/root/EventBus"

func _input(_event: InputEvent) -> void:
	check_toggle_main_menu()

func check_toggle_main_menu() -> void:
	if Input.is_action_just_pressed("toggle_main_menu"):
		event_bus.emit_signal("toggle_main_menu")
