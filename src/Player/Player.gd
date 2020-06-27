extends KinematicBody2D

const CustomCamera = preload("res://src/Player/Camera2D.gd")
const LightningSpell: PackedScene = preload("res://src/Spell/LightningSpell.tscn")
const FireSpell: PackedScene = preload("res://src/Spell/FireSpell.tscn")
const BloodSplatter: PackedScene = preload("res://src/Enemy/BloodSplatter.tscn")

enum DirectionFacing {
	LEFT,
	RIGHT
}

enum PlayerAnimation {
	WALK,
	HOVER,
	FALL,
	IDLE
}

const GROUP_ENEMY: String = "Enemy"
const GROUP_PLAYER: String = "Player"
const GRAVITY_VEC: Vector2 = Vector2(0, 1000)
const MAX_FALL_SPEED: float = 500.0
const FLOOR_NORMAL: Vector2 = Vector2(0, -1)
const SLOPE_SLIDE_STOP: float = 25.0
const WALK_SPEED: float = 180.0 # pixels/sec
const JUMP_SPEED: float = 550.0
const SIDING_CHANGE_SPEED: float = 70.0
const LERP_SPEED: float = 0.2

const ANIMATIONS = {
	PlayerAnimation.WALK: "walk",
	PlayerAnimation.HOVER: "hover",
	PlayerAnimation.FALL: "fall",
	PlayerAnimation.IDLE: "idle"
}

var last_checkpoint: Vector2
var score: int = 0
var max_health: float = 100.0
var max_energy: float = 100.0
var health: float = 100.0
var energy: float = 100.0
var damage: float = 10.0
var spell_damage: float = 10.0
var linear_velocity: Vector2 = Vector2.ZERO
var anim: String = ""
var weaponAnim: String = ""
var can_attack: bool = true
var should_hover: bool = false
var has_weapon: bool = false
var has_lazarus: bool = false
var lazarusUsed: bool = false
var skills_acquired: int = 0
var selected_skill: int = 0
var fall_limit: float = 3000.0
var level: int = 1

onready var gui_spell_lightning: TextureRect = $"/root/MainScene/GUI/LightningSpell"
onready var gui_spell_fire: TextureRect = $"/root/MainScene/GUI/FireSpell"
onready var gui_spell_holy: TextureRect = $"/root/MainScene/GUI/HolySpell"
onready var gui_spell_ice: TextureRect = $"/root/MainScene/GUI/IceSpell"
onready var gui_lazarus: Sprite = $"/root/MainScene/GUI/Lazarus"
onready var gui_health: TextureProgress = $"/root/MainScene/GUI/Health"
onready var gui_energy: TextureProgress = $"/root/MainScene/GUI/Divinity"
onready var gui_damage: Label = $"/root/MainScene/GUI/Damage"
onready var gui_spell_damage: Label = $"/root/MainScene/GUI/SpellDamage"
onready var gui_score: Label = $"/root/MainScene/GUI/Halos"

onready var camera2d: CustomCamera = $Camera2D
onready var sprite: Sprite = $Sprite
onready var spells: Node2D = $Spells
onready var tween: Tween = $Tween
onready var skill_timer: Timer = $SkillTimer
onready var weapon_area2d: Area2D = $Sprite/WeaponArea
onready var weapon_sprite: Sprite = $Sprite/Weapon
onready var spell_area2d: Area2D = $Spells/AreaOfEffect
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var weapon_animation_player: AnimationPlayer = $Sprite/WeaponAnimationPlayer
onready var spell_holy: Particles2D = $Spells/HolySpell
onready var spell_ice: Particles2D = $Spells/IceSpell
onready var sfx_slash: AudioStreamPlayer2D = $Slash
onready var sfx_lightning: AudioStreamPlayer2D = $Lightning
onready var sfx_footstep: AudioStreamPlayer2D = $FootStep
onready var sfx_pickup: AudioStreamPlayer2D = $PickUp
onready var gui_spells: Array = [gui_spell_lightning, gui_spell_fire, gui_spell_holy, gui_spell_ice]

func _ready() -> void:
	EventBus.connect("player_animation", self, "_on_player_animation")

	gui_health.max_value = health
	gui_health.value = health
	gui_energy.max_value = energy
	gui_energy.value = energy
	last_checkpoint = global_position

func _physics_process(delta) -> void:
	if can_attack:
		if has_weapon and Input.is_action_just_pressed("light_attack"):
			if weapon_animation_player.current_animation == "light_attack_1":
				weapon_animation_player.play("light_attack_2")
			else:
				weapon_animation_player.play("light_attack_1")
			hover()
			can_attack = false
		elif energy > 5 and Input.is_action_pressed("magic_attack") and skills_acquired > 0:
			skill_timer.start()
			spell_hit()
			var spell
			if selected_skill == 1:
				spell = LightningSpell.instance()
			elif selected_skill == 2:
				spell = FireSpell.instance()
			elif selected_skill == 3:
				spell_holy.emitting = true
			elif selected_skill == 4:
				spell_ice.emitting = true
			if spell:
				spell.position = spells.global_position
				get_parent().add_child(spell)
			energy -= 5
			gui_energy.value = energy

			hover()

			can_attack = false
			sfx_lightning.play()

	if !should_hover:
		animation_player.play(anim)
		if anim == "walk" and !sfx_footstep.playing:
			sfx_footstep.playing = true
		elif anim != "walk" and sfx_footstep.playing:
			sfx_footstep.stop()

"""
Listens for event to change the player animation using enum
"""
func _on_player_animation(animation) -> void:
	anim = ANIMATIONS[animation]

func get_hit(_damage):
	health -= _damage
	if _damage > 0:
		camera2d.shake(0.2, 12, 6)
	if health <= 0:
		if has_lazarus and !lazarusUsed:
			lazarusUsed = true
			gui_lazarus.visible = false
		else:
			EventBus.emit_signal("player_respawn")
			lazarusUsed = false
			gui_lazarus.visible = true
		health = 100
	gui_health.value = health

func hit():
	if has_weapon:
		for body in weapon_area2d.get_overlapping_bodies():
			if body.is_in_group(GROUP_ENEMY) and !body.dead:
				body.get_hit(self,damage)
				sfx_slash.play()
				camera2d.shake(0.3, 12, 10)
				var bs = BloodSplatter.instance()
				bs.start(body.global_position,sprite.flip_h)
				get_parent().call_deferred("add_child",bs)

func spell_hit():
	for body in spell_area2d.get_overlapping_bodies():
		if body.is_in_group(GROUP_ENEMY):
			damage += 15
			body.get_hit(self, spell_damage)
			damage -= 15

func hover():
	should_hover = true
	animation_player.play(ANIMATIONS[PlayerAnimation.HOVER])
	tween.interpolate_property(
		sprite,
		"offset:y",
		sprite.offset.y,
		-8,
		1,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)
	tween.start()

func stop_hovering():
	can_attack = true
	tween.interpolate_property(
		sprite,
		"offset:y",
		sprite.offset.y,
		0,
		1,
		Tween.TRANS_QUINT,
		Tween.EASE_IN
	)
	tween.start()

func _on_Tween_tween_all_completed():
	if sprite.offset.y == 0:
		should_hover = false

func get_skill(skillNumber):
	if skills_acquired < 5 and skillNumber > skills_acquired:
		skills_acquired += 1
		if skills_acquired == 1:
			selected_skill = 1
			gui_spell_lightning.visible = true
			gain_spell_damage(0)
			gui_spell_damage.visible = true
		elif skills_acquired == 2:
			selected_skill = 2
			gui_spell_fire.visible = true
			gain_spell_damage(5)
		elif skills_acquired == 3:
			selected_skill = 3
			gui_spell_holy.visible = true
			gain_spell_damage(5)
		elif skills_acquired == 4:
			selected_skill = 4
			gui_spell_ice.visible = true
			gain_spell_damage(5)
		elif skills_acquired == 5:
			has_lazarus = true
			lazarusUsed = false
			gui_lazarus.visible = true
		set_selected_skill_ui()

func gain_spell_damage(points):
	sfx_pickup.play()
	if spell_damage < 200:
		spell_damage += points
	gui_spell_damage.text = "Spell Damage: " + str(spell_damage)

func set_selected_skill_ui():
	for sui in gui_spells.size():
		if sui + 1 == selected_skill:
			gui_spells[sui].get_node("Frame").visible = true
		else:
			gui_spells[sui].get_node("Frame").visible = false

func get_weapon(weapon):
	if !has_weapon:
		has_weapon = true
		gui_damage.visible = true
	if weapon.damage > damage:
		weapon_sprite.texture = weapon.sprite.texture
		damage = weapon.damage
	gui_damage.text = "Damage: " + str(damage)
	sfx_pickup.play()
	gain_points(100)

func loot_energy():
	if energy < max_energy:
		if energy + 3 <= max_energy:
			energy += 3
		else:
			energy = max_energy
		gui_energy.value = energy
	if health < max_health:
		if health < max_health:
			health += 1
		else:
			health = max_health
		gui_health.value = health
	sfx_pickup.play()
	gain_points(10)

func gain_points(points):
	score += points
	gui_score.gain_points(score)

func _on_skill_timer_timeout():
	stop_hovering()
	if spell_holy.emitting:
		spell_holy.emitting = false
	elif spell_ice.emitting:
		spell_ice.emitting = false
	can_attack = true

func set_limits(left, right, fall):
	camera2d.limit_left = left
	camera2d.limit_right = right
	fall_limit = fall
