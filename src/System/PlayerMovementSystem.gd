extends Node

const Player = preload("res://src/Player/Player.gd")

onready var event_bus: EventBus = $"/root/EventBus"
onready var player: Player = $"/root/MainScene/WorldEnvironment/Player"

func _ready() -> void:
	event_bus.connect("player_respawn", self, "_on_player_respawn")
	event_bus.connect("player_change_facing", self, "_on_player_change_facing")

func _physics_process(delta) -> void:
	# MOVEMENT
	if player.linear_velocity.y < Player.MAX_FALL_SPEED:
		player.linear_velocity += delta * Player.GRAVITY_VEC

	if player.position.y > player.fall_limit:
		event_bus.emit_signal("player_respawn")

	player.linear_velocity = player.move_and_slide(player.linear_velocity, Player.FLOOR_NORMAL, Player.SLOPE_SLIDE_STOP)

	var on_floor = player.is_on_floor()

	# CONTROL
	var target_speed = 0

	if Input.is_action_pressed("left"):
		target_speed -= 1

	if Input.is_action_pressed("right"):
		target_speed += 1

	target_speed *= Player.WALK_SPEED

	# slippery amount
	player.linear_velocity.x = lerp(player.linear_velocity.x, target_speed, Player.LERP_SPEED)

	if on_floor and Input.is_action_just_pressed("jump"):
		player.linear_velocity.y = -Player.JUMP_SPEED

func _on_player_respawn() -> void:
	player.global_position = player.lastCheckPointPos

func _on_player_change_facing(direction) -> void:
	match direction:
		Player.DirectionFacing.LEFT:
			face_left()
		Player.DirectionFacing.RIGHT:
			face_right()

func face_left():
	player.sprite.scale.x = -1
	player.spells.position.x = -130

func face_right():
	player.sprite.scale.x = 1
	player.spells.position.x = 130
