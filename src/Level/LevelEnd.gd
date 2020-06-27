extends Area2D

export var level: int = 1

const MAX_LEVEL: int = 9

var levelInstance: Resource
var player
var baseBrightness: float = 0.9
var activated: bool = false

onready var tween: Tween = $Tween
onready var worldEnv: WorldEnvironment = get_node("/root/MainScene/WorldEnvironment")
onready var event_bus: EventBus = $"/root/EventBus"

func _ready():
	tween.interpolate_property(worldEnv.environment, "adjustment_brightness", 0, baseBrightness, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

func _on_LevelEnd_body_entered(body):
	if !activated and body.is_in_group("Player"):
		activated = true

		if level < MAX_LEVEL:
			levelInstance = load("res://Level" + str(level + 1) + ".tscn").instance()

		player = body
		tween.interpolate_property(worldEnv.environment, "adjustment_brightness", baseBrightness, 0, 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.start()

func _on_Tween_tween_all_completed():
	if worldEnv.environment.adjustment_brightness == 0:
		get_parent().get_parent().call_deferred("add_child",levelInstance)
		player.global_position = levelInstance.get_node("SpawnPosition").global_position
		player.lastCheckPointPos = player.global_position
		player.level = level

		event_bus.emit_signal("save_game")

		var leftCamLimit = levelInstance.get_node("Limiters/LeftCamLimit").global_position.x
		var rightCamLimit = levelInstance.get_node("Limiters/RightCamLimit").global_position.x
		var fallLimit = levelInstance.get_node("Limiters/FallLimit").global_position.y
		player.set_limits(leftCamLimit,rightCamLimit,fallLimit)
		get_parent().queue_free()
