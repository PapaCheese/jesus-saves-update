extends Area2D

export var damage = 15

var looted: bool = false

onready var sprite = $Sprite

func _ready():
	$Label.text = str(damage) + " DAMAGE"

func _on_SkillPrayer_body_entered(body):
	if !looted and body.is_in_group("Player"):
		looted = true
		body.get_weapon(self)
		$AnimationPlayer.play("looted")
