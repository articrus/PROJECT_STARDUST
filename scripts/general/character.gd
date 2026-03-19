class_name Character
extends Node
# Written By: Gianni Coladonato
# Date Created / Modified: 06-10-2025 / 18-03-2026
# Basic Info
@export var chara_name : String = "BLANK"
@export var hp: Vector2i = Vector2i(100, 100) # Current / Max
# Skills & stats
@export var abilities: Vector3i = Vector3i(6, 6, 6) # Melee Damage / Ranged Damage / Skill Damage
# Position
@export var rank : int = 0
# Modifiers/Tokens
@export var atk: Vector3i = Vector3i(0, -2, 3) # Attack Bonus, Min / Max
@export var def: Vector3i = Vector3i(0, -2, 3) # Defense Bonus, Min / Max
@export var crt: Vector3i = Vector3i(0, 0, 2) # Crit Bonus Min / Max
@export var eva: Vector3i = Vector3i(0, 0, 3) # Evasion chance, Min / Max
# General
@export var is_alive: bool = true:
	set(value):
		is_alive = value
		if animation_node:
			if is_alive:
				animation_node._revive()
			else:
				animation_node._down()
@export var skill_list: Array[Skill]
@export var char_attack : Skill
# Marked and Debuffs
var is_marked: bool = false
var mark_duration: int = 0
var is_stunned: bool = false
# Other compopnents
var buff_container
var animation_node
# For health bar component
signal hp_changed(hp)

func _ready() -> void:
	pass

# Deal damage to an entity
func _hurt(damage : int) -> void:
	if hp.x - damage <= 0:
		hp.x = 0
	else:
		hp.x -= damage
	is_alive = hp.x > 0 # If below 0, go down
	hp_changed.emit(hp)

# Heal an entity
func _heal(healing : int) -> void:
	if hp.x + healing > hp.y:
		hp.x = hp.y
	else:
		hp.x += healing
	is_alive = hp.x > 0 # If a downed player is healed, they are revived
	hp_changed.emit(hp)

# Determine if attack or skill is a crit
func _is_crit() -> bool: 
	var crit_chance = 1 + Token_Utils._get_crt_bonus(self) # 1 is a 5# chance 10 is 50%
	var roll = randi_range(1,20)
	return roll <= crit_chance

func _attack_damage() -> int:
	var damage = 1 + Token_Utils._get_atk_bonus(self)
	if rank < 2:
		damage *= randi_range(ceil(abilities.x / 2.0), abilities.x) # Melee Damage
	else:
		damage *= randi_range(ceil(abilities.y / 2.0), abilities.y) # Ranged Damage
	return int(damage)

func _damage_reduction(damage: int) -> float:
	var reduction = damage * (1 - Token_Utils._get_def_bonus(self))
	return int(reduction)

# Determine if a character dodges an attack
func _does_actor_dodge() -> bool:
	if eva.x <= 0:
		return false # No active dodge tokens
	else:
		var roll = randi_range(0,3)
		if Token_Utils._get_eva_bonus(self) >=  1: #Big buff or greater
			return roll <= 2 # 75% to be less than or equal to 2 (0,1,2)
		else:
			return roll % 2 == 0 # 50% to be even

func _remove_mark() -> void:
	is_marked = false
	buff_container._toggle_mark(false)
	mark_duration = 0

func _end_of_turn_checks() -> void:
	if mark_duration > 0 && is_marked:
		mark_duration -= 1
		if mark_duration == 0:
			_remove_mark()
	if is_stunned: #Stun is a one-turn condition
		is_stunned = false

func _mark_actor(duration: int):
	is_marked = true
	mark_duration = duration
	
func _load_player_data(data: Player_Data):
	data._load_player_data(self)
