extends Area2D

var looted: bool = false

func _on_EnergyLoot_body_entered(body) -> void:
	if !looted and body.is_in_group("Player"):
		looted = true
		body.gain_spell_damage(2)
		$halo.visible = false
		$AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
