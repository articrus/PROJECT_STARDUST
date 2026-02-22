extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified : 26-10-2025 / 30-01-2026
# Scene Components
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
# Export vars
@export var sprite_sheet: Texture
@export var enemy_state = enums.ENEMY_STATE
@export var is_battle: bool
@export var is_down: bool = false

func _ready() -> void:
	sprite.texture = sprite_sheet
	is_battle = false

func _process(_delta: float) -> void:
	_play_animation()

func _play_animation() -> void:
	var target_anim: StringName
	match enemy_state:
		enums.ENEMY_STATE.IDLE:
			target_anim = Animation_Strings.enemy_idle
		enums.ENEMY_STATE.BATTLE:
			target_anim = Animation_Strings.enemy_battle
		enums.ENEMY_STATE.M_ATTACK:
			target_anim = Animation_Strings.enemy_melee_attack
		enums.ENEMY_STATE.R_ATTACK:
			target_anim = Animation_Strings.enemy_ranged_attack
		enums.ENEMY_STATE.SKILL:
			target_anim = Animation_Strings.enemy_skill
		enums.ENEMY_STATE.HIT:
			target_anim = Animation_Strings.enemy_hit
		enums.ENEMY_STATE.DOWN:
			target_anim = Animation_Strings.enemy_die
	# If different then current animation, play it
	if anim_player.current_animation != target_anim:
		anim_player.play(target_anim)

func _enter_battle(toggle: bool):
	if toggle:
		enemy_state = enums.ENEMY_STATE.IDLE
	else:
		enemy_state = enums.ENEMY_STATE.BATTLE
	is_battle = toggle

func _attack(rank: int):
	if rank < 2:
		enemy_state = enums.ENEMY_STATE.M_ATTACK
	else:
		enemy_state = enums.ENEMY_STATE.R_ATTACK

func _skill():
	enemy_state = enums.ENEMY_STATE.SKILL

func _perform_skill():
	Signalbus.perform_skill.emit()

func _hit():
	enemy_state = enums.ENEMY_STATE.HIT

func _down():
	enemy_state = enums.ENEMY_STATE.DOWN

func _revive():
	_enter_battle(is_battle)

func _kill_target():
	self.get_parent().queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in [Animation_Strings.enemy_melee_attack, Animation_Strings.enemy_ranged_attack,
	Animation_Strings.enemy_skill, Animation_Strings.enemy_hit]:
		if is_battle:
			enemy_state = enums.PLAYER_STATE.BATTLE
		elif anim_name == Animation_Strings.enemy_die:
			pass # Stay in down/dead animation
		else:
			enemy_state = enums.PLAYER_STATE.IDLE
