extends Area2D

var looted: bool = false

onready var halo: Sprite = $halo
onready var animated_sprite: AnimatedSprite = $AnimatedSprite

func _on_EnergyLoot_body_entered(body) -> void:
	if !looted and body.is_in_group("Player"):
		looted = true
		body.loot_energy()
		halo.visible = false
		animated_sprite.play()

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
