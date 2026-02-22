extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified : 23-10-2025 / 12-02-2026
# Object Components
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
# Variables
@export var player_state: enums.PLAYER_STATE
@export var is_moving : bool :
	get:
		return is_moving
	set(new_value):
		if new_value:
			player_state = enums.PLAYER_STATE.MOVING
		else:
			player_state = enums.PLAYER_STATE.IDLE
@export var is_battle : bool 
@export var sprite_sheet : Texture

func _ready() -> void:
	sprite.texture = sprite_sheet
	is_battle = false

func _process(_delta: float) -> void:
	_play_animation()

func _play_animation():
	var target_anim: StringName
	match player_state:
		enums.PLAYER_STATE.IDLE:
			target_anim = Animation_Strings.player_idle
		enums.PLAYER_STATE.MOVING:
			target_anim = Animation_Strings.player_moving
		enums.PLAYER_STATE.BATTLE:
			target_anim = Animation_Strings.player_battle
		enums.PLAYER_STATE.M_ATTACK:
			target_anim = Animation_Strings.player_melee_attack
		enums.PLAYER_STATE.R_ATTACK:
			target_anim = Animation_Strings.player_ranged_attack
		enums.PLAYER_STATE.SKILL:
			target_anim = Animation_Strings.player_skill
		enums.PLAYER_STATE.HIT:
			target_anim = Animation_Strings.player_hit
		enums.PLAYER_STATE.DOWN:
			target_anim = Animation_Strings.player_down
	# If different then current animation, play it
	if anim_player.current_animation != target_anim:
		anim_player.play(target_anim)

func _enter_battle(toggle: bool):
	if toggle:
		player_state = enums.PLAYER_STATE.BATTLE
	else:
		player_state = enums.PLAYER_STATE.IDLE
	is_battle = toggle

func _attack(rank: int):
	if rank < 2:
		player_state = enums.PLAYER_STATE.M_ATTACK
	else:
		player_state = enums.PLAYER_STATE.R_ATTACK

func _hit():
	player_state = enums.PLAYER_STATE.HIT

func _perform_skill():
	Signalbus.perform_skill.emit()

func _skill():
	player_state = enums.PLAYER_STATE.SKILL

func __skill(index: int) -> void:
	match index:
		0: # Melee Attack
			player_state = enums.PLAYER_STATE.M_ATTACK
		1: # Ranged Attack
			player_state = enums.PLAYER_STATE.R_ATTACK
		2: # Skill 1
			player_state = enums.PLAYER_STATE.SKILL
		3: # Skill 2... ect...
			player_state = enums.PLAYER_STATE.SKILL

func _down():
	player_state = enums.PLAYER_STATE.DOWN

func _revive():
	_enter_battle(is_battle)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in [Animation_Strings.player_melee_attack, Animation_Strings.player_ranged_attack,
	Animation_Strings.player_skill, Animation_Strings.player_hit]:
		if is_battle:
			player_state = enums.PLAYER_STATE.BATTLE
		elif anim_name == Animation_Strings.player_down:
			pass # Skip if down
		else:
			player_state = enums.PLAYER_STATE.IDLE
