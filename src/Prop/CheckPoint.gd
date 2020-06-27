extends AnimatedSprite

var checked: bool = false

onready var event_bus = $"/root/EventBus"

func _on_Area2D_body_entered(body: Node) -> void:
	if !checked and body.is_in_group("Player"):
		body.last_checkpoint = global_position
		checked = true
		$Label.visible = true
		event_bus.emit_signal("save_game", {}, 0)
		$CheckPointSound.play()
		$Tween.interpolate_property(self,"offset:y",offset.y, 24,2,Tween.TRANS_QUINT,Tween.EASE_OUT)
		$Tween.start()
