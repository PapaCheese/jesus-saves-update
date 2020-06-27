extends Node

const Player = preload("res://src/Player/Player.gd")

onready var event_bus: EventBus = $"/root/EventBus"
onready var player: Player = $"/root/MainScene/WorldEnvironment/Player"

func _input(event) -> void:
	if player.skills_acquired > 1:
		if Input.is_action_just_pressed("weapon_up"):
			if player.selected_skill < player.skills_acquired:
				player.selected_skill += 1
			else:
				player.selected_skill = 1

		if Input.is_action_just_pressed("weapon_down"):
			if player.selected_skill > 1:
				player.selected_skill -= 1
			else:
				player.selected_skill = player.skills_acquired

		if event is InputEventKey:
			if event.pressed and event.scancode == KEY_1:
				player.selected_skill = 1
			if event.pressed and event.scancode == KEY_2 and player.skills_acquired > 1:
				player.selected_skill = 2
			if event.pressed and event.scancode == KEY_3 and player.skills_acquired > 2:
				player.selected_skill = 3
			if event.pressed and event.scancode == KEY_4 and player.skills_acquired > 3:
				player.selected_skill = 4

		player.set_selected_skill_ui()
