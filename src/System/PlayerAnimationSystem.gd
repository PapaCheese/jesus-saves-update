extends Node

const Player = preload("res://src/Player/Player.gd")

onready var event_bus: EventBus = $"/root/EventBus"
onready var player: Player = $"/root/MainScene/WorldEnvironment/Player"

func _physics_process(delta) -> void:
	# ANIMATION
	event_bus.emit_signal("player_animation", Player.PlayerAnimation.IDLE)

	if player.is_on_floor():
		if player.linear_velocity.x < -Player.SIDING_CHANGE_SPEED:
			event_bus.emit_signal("player_change_facing", Player.DirectionFacing.LEFT)
			event_bus.emit_signal("player_animation", Player.PlayerAnimation.WALK)

		if player.linear_velocity.x > Player.SIDING_CHANGE_SPEED:
			event_bus.emit_signal("player_change_facing", Player.DirectionFacing.RIGHT)
			event_bus.emit_signal("player_animation", Player.PlayerAnimation.WALK)
	else:
		if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
			event_bus.emit_signal("player_change_facing", Player.DirectionFacing.LEFT)

		if Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
			event_bus.emit_signal("player_change_facing", Player.DirectionFacing.RIGHT)

		if player.linear_velocity.y < 0:
			event_bus.emit_signal("player_animation", Player.PlayerAnimation.HOVER)
		else:
			event_bus.emit_signal("player_animation", Player.PlayerAnimation.FALL)
