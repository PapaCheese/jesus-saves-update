extends Area2D

export var skillNumber := 1

var looted: bool = false

func _on_SkillPrayer_body_entered(body) -> void:
	if !looted and body.is_in_group("Player"):
		looted = true
		body.get_skill(skillNumber)
		$AnimationPlayer.play("looted")
