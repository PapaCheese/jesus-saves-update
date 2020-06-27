extends Node2D

func _ready():
	EventBus.emit_signal("load_game", 0)
