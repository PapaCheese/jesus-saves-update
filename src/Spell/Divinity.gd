extends Label

onready var animPlayer = $AnimationPlayer

func gain_points(score) -> void:
	text = str(score)
	animPlayer.play("gain")
