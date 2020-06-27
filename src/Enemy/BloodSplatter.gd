extends AnimatedSprite

func start(pos,flip):
	global_position = pos + Vector2(rand_range(0,8),rand_range(0,16))
	flip_h = flip

func _ready():
	play()

func _on_BloodSplatter_animation_finished():
	queue_free()
