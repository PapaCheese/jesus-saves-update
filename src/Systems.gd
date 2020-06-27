extends Node2D

"""
This is a container for all systems, and controls loading various systems (in order).

Disabling a system should disable that particular system functionality from running, theoretically the
rest of the game would still work.
"""
var _systems = {
	"InputSystem": preload("res://src/System/InputSystem.gd").new(),
	"EngineSystem": preload("res://src/System/EngineSystem.gd").new(),
	"SaveSystem": preload("res://src/System/SaveSystem.gd").new(),
	"PlayerMovementSystem": preload("res://src/System/PlayerMovementSystem.gd").new(),
	"PlayerAttackSystem": preload("res://src/System/PlayerAttackSystem.gd").new(),
	"PlayerAnimationSystem": preload("res://src/System/PlayerAnimationSystem.gd").new()
}

func _ready() -> void:
	for name in _systems:
		_systems[name].name = name
		add_child(_systems[name])
