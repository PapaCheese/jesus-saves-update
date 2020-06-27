extends AudioStreamPlayer

func _ready():
	$Tween.interpolate_property(self,"volume_db",volume_db,0,2,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

