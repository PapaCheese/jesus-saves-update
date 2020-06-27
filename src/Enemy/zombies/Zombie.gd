extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 1200)
const MAX_FALL_SPEED = 500
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 75 # pixels/sec

export var damage: float = 5

var health: float = 100
var linear_vel = Vector2()
var facingLeft: bool = true
var canAttack: bool = true
var dead: bool = false
var knockedBack: bool = false
var target

onready var sprite: Sprite = $Sprite
onready var animPlayer: AnimationPlayer = $AnimationPlayer
onready var leftAttackArea = $LeftAttackArea
onready var rightAttackArea = $RightAttackArea
onready var attackTimer: Timer = $AttackTimer
onready var hpBar = $HpBar

func _ready():
	if is_in_group("Boss"):
		health += 700
	hpBar.max_value = health
	hpBar.value = health

func _process(delta):
	if !dead and target and animPlayer.current_animation != "hit" and animPlayer.current_animation != "attack" and !knockedBack:
		var dis = global_position - target.global_position
		if dis.x < 50 and dis.x > -50 and canAttack:
			play_attack_anim(target)
		else:
			var spd = -dis.normalized().x
			if spd > 0:
				face_left(false)
			elif spd < 0:
				face_left(true)
			linear_vel.x = spd * WALK_SPEED
			if spd > 0.2 or spd < -0.2:
				animPlayer.play("walk")
			else:
				animPlayer.play("idle")
	### MOVEMENT ###
	# Apply gravity
	if !dead and linear_vel.y < MAX_FALL_SPEED:
		linear_vel += delta * GRAVITY_VEC
	if knockedBack:
		if linear_vel.x > 0:
			linear_vel.x -= delta * 500
			if linear_vel.x <= 0:
				linear_vel.x = 0
				knockedBack = false
		else:
			linear_vel.x += delta * 500
			if linear_vel.x >= 0:
				linear_vel.x = 0
				knockedBack = false

	# Move and slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
#	var on_floor = is_on_floor()

func get_hit(body,_damage):
	if !dead:
		if !target:
			target = body
		health -= _damage
		if health <= 0:
			die()
		animPlayer.play("hit")
		knock_back()
		hpBar.value = health

func knock_back():
	knockedBack = true
	if target.global_position.x > global_position.x:
		linear_vel.x = -220
	else:
		linear_vel.x = 220

func die():
	if !dead:
		dead = true
		animPlayer.play("die")
		linear_vel.x = 0
		collision_mask = 32
		target.gain_points(50)
		if is_in_group("Boss") and get_parent().get_parent().has_method("spawn_crate"):
			get_parent().get_parent().spawn_crate()
			target.gain_points(250)

func _on_WalkTimer_timeout():
	if !dead and !target:
		if animPlayer.current_animation != "attack" and animPlayer.current_animation != "hit":
			var rnd = rand_range(1,-1)
			if rnd < 0.5 and rnd > -0.5:
				rnd =0
				animPlayer.play("idle")
			else:
				animPlayer.play("walk")
			linear_vel.x = rnd * WALK_SPEED
			if rnd > 0:
				face_left(false)
			elif rnd < 0:
				face_left(true)

func face_left(boo: bool):
	sprite.flip_h = !boo
	facingLeft = boo
	if boo:
		$FloorArea.position.x = -30
	else:
		$FloorArea.position.x = 30


func attack():
	var area: Area2D
	if facingLeft:
		area = leftAttackArea
	else:
		area = rightAttackArea
#	target.get_hit(damage)
	for a in area.get_overlapping_bodies():
		if a.is_in_group("Player"):
			a.get_hit(damage)

func _on_LeftAttackArea_body_entered(body):
	if !dead:
#		face_left(true)
		play_attack_anim(body)

func _on_RightAttackArea_body_entered(body):
	if !dead:
#		face_left(false)
		play_attack_anim(body)

func play_attack_anim(body):
	if !dead and animPlayer.current_animation != "hit":
		if body.is_in_group("Player"):
			if !target:
				target = body
			if animPlayer.current_animation != "hit":
				animPlayer.play("attack")
				canAttack = false
				attackTimer.start()
			linear_vel.x = 0
		else:
			linear_vel.x *= -1
			face_left(!facingLeft)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit" and dead:
		animPlayer.play("die")

func _on_AttackTimer_timeout():
	canAttack = true

func _on_FloorArea_body_exited(body):
	linear_vel.x *= -1
	face_left(!facingLeft)
#	$FloorArea.position.x /= -1
