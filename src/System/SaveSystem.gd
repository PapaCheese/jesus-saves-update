extends Node

const Player = preload("res://src/Player/Player.gd")

const SAVE_FILENAME: String = "user://savegame.json"

onready var event_bus = $"/root/EventBus"
onready var world_environment: WorldEnvironment = $"/root/MainScene/WorldEnvironment"
onready var player: Player = $"/root/MainScene/WorldEnvironment/Player"

func _ready() -> void:
	event_bus.connect("save_game", self, "_on_save_game")
	event_bus.connect("load_game", self, "_on_load_game")

"""
Refactor other code later to eventually pass the data to the event?
"""
func _on_save_game(_state: Dictionary = {}, _slot: int = 0) -> void:
	var player: Player = $"/root/MainScene/WorldEnvironment/Player"

	var weapon_sprite
	if player.weapon_sprite.texture:
		weapon_sprite = player.weapon_sprite.texture.get_path()

	var data = {
		"level": player.level,
		"last_checkpoint": {
			"x": player.last_checkpoint.x,
			"y": player.last_checkpoint.y
		},
		"health": player.health,
		"energy": player.energy,
		"damage": player.damage,
		"weapon_sprite": weapon_sprite,
		"skills_acquired": player.skills_acquired,
		"spell_damage": player.spell_damage,
		"score": player.score,
	}

	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(data))
	save_game.close()

	print("Game Saved")

func _on_load_game(_slot: int = 0) -> void:
	var save_game = File.new()
	if not save_game.file_exists(SAVE_FILENAME):
		event_bus.emit_signal("save_game", {}, 0)
		return # Error! We don't have a save to load.

	save_game.open(SAVE_FILENAME, File.READ)

	var data = {}
	while save_game.get_position() < save_game.get_len():
		data = parse_json(save_game.get_line())

	save_game.close()

	load_game(data)

func load_game(data) -> void:
	if data["level"] > 1 :
		var level_instance: Node2D = load("res://src/Level/Level" + str(data["level"] + 1) + ".tscn").instance()

		world_environment.add_child(level_instance)
		player.global_position = level_instance.get_node("SpawnPosition").global_position
		player.last_checkpoint = player.global_position
		player.level = data["level"]

		var left_cam_limit = level_instance.get_node("Limiters/LeftCamLimit").global_position.x
		var right_cam_limit = level_instance.get_node("Limiters/RightCamLimit").global_position.x
		var fall_limit = level_instance.get_node("Limiters/FallLimit").global_position.y

		player.set_limits(left_cam_limit, right_cam_limit, fall_limit)
		get_node("/root/MainScene/WorldEnvironment/Level1").queue_free()

	if data["last_checkpointX"]:
		player.last_checkpoint = Vector2(data["last_checkpoint"].x, data["last_checkpoint"].y)
		player.position = player.last_checkpoint

	if data["health"]:
		player.health = data["health"]
		player.get_hit(0)

	if data["energy"]:
		player.energy = data["energy"]
		player.loot_energy()

	if data["damage"]:
		player.damage = data["damage"]
		player.gui_damage.text = "Damage: " + str(player.damage)

	if data["weapon_sprite"]:
		player.weapon_sprite.texture = load(data["weapon_sprite"])
		player.has_weapon = true
		player.gui_damage.visible = true

	if data["skills_acquired"]:
		for i in data["skills_acquired"]:
			player.get_skill(i+1)

	if data["spell_damage"]:
		player.spell_damage = data["spell_damage"]
		player.gain_spell_damage(0)

	if data["score"]:
		player.score = data["score"]
		player.gain_points(0)

	print("Game Loaded")
