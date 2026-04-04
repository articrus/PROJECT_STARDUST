extends Node
class_name Token_Utils
# Written By: Gianni Coladonato
# Date Created/Modificed: 02-12-2025 | 04-04-2026

# Buff a stat
static func _apply_stat_buff(stat: Vector3i, value: int) -> int:
	var big_buffs = (stat.x / 10)
	var small_buffs = int(fmod(stat.x, 10))
	if value < 0: # Debuff
		if big_buffs > 0: # If has a big buff, remove it and add a small buff
			var new_big = clamp(((big_buffs + value) * 10), 0, (stat.z * 10))
			var new_small = clamp(small_buffs + abs(value), stat.y, stat.z)
			stat.x = new_big + new_small
		elif small_buffs > 0: # If has a small buff, absorb it
			stat.x = clamp(small_buffs + value, stat.y, stat.z)
		else: # No buffs present, just debuff
			stat.x = clamp((stat.x + value), stat.y, stat.z)
	elif value >= 10: # Greater buff
		var new_value = (big_buffs * 10) + value
		stat.x = clamp(new_value, 0, (stat.z * 10)) + small_buffs
	else: # Regular buff
		var new_value = stat.x + value
		stat.x = clamp(new_value, 0, stat.z)
	return stat.x

static func _atk_buff(chara: Character, buff_amount: int) -> void:
	chara.atk.x = _apply_stat_buff(chara.atk, buff_amount)
	chara.buff_container._update_atk_tokens(chara.atk.x)

static func _def_buff(chara: Character, buff_amount: int) -> void:
	chara.def.x  = _apply_stat_buff(chara.def, buff_amount)
	chara.buff_container._update_def_tokens(chara.def.x)

static func _crt_buff(chara: Character, buff_amount: int) -> void:
	chara.crt.x  = _apply_stat_buff(chara.crt, buff_amount)
	chara.buff_container._update_crt_tokens(chara.crt.x)

static func _eva_buff(chara: Character, buff_amount: int) -> void:
	chara.eva.x  = _apply_stat_buff(chara.eva, buff_amount)
	chara.buff_container._update_eva_tokens(chara.eva.x)

# Debuff the character's accuracy (to implement)
static func _acc_debuff(chara: Character, buff_amount: int) -> void:
	chara.crt.x  = _apply_stat_buff(chara.crt, buff_amount)
	chara.buff_container._update_crt_tokens(chara.crt.x)

static func _get_stat_bonus(stat: Vector3, max_amount: float, debuff_amount: float) -> float:
	if stat.x >= 10:
		return max_amount
	elif stat.x > 0:
		return 1.5
	elif stat.x < 0:
		return debuff_amount
	else:
		return 1

# For displaying in the battlehud/checking token counts
static func _get_atk_bonus_for_display(chara: Character) -> float:
	return _get_stat_bonus(chara.atk, 1.75, 0.5)

static func _get_def_bonus_for_display(chara: Character) -> float:
	return _get_stat_bonus(chara.def, 0.25, 1.5)

# Consumes the stat token and returns the buff value
static func _consume_stat_token(stat: Vector3, regular_bonus: float, max_bonus: float, debuff_value: float) -> Array:
	var to_return = 0
	if stat.x >= 10:
		to_return = max_bonus
		stat.x -= 10 # Remove 1 big buff
	elif stat.x < 0:
		to_return = debuff_value
		stat.x += 1 # Move back towards zero
	elif stat.x > 0:
		to_return = regular_bonus
		stat.x -= 1 # Remove regular buff
	else:
		to_return = 0
	return [to_return, stat]

# Returns the character's attack bonus
static func _get_atk_bonus(chara: Character) -> float:
	if chara.atk.x == 0:
		return 0
	var atk_bonus = _consume_stat_token(chara.atk, 0.5, 0.75, -0.5)
	chara.atk.x = atk_bonus[1].x
	chara.buff_container._update_atk_tokens(chara.atk.x)
	return atk_bonus[0]

static func _get_def_bonus(chara: Character) -> float:
	if chara.def.x == 0:
		return 0
	var def_bonus = _consume_stat_token(chara.def, 0.5, 0.75, -0.5)
	chara.def.x = def_bonus[1].x
	chara.buff_container._update_def_tokens(chara.def.x)
	return def_bonus[0]

static func _get_crt_bonus(chara: Character) -> int:
	if chara.crt.x == 0:
		return 0
	var crt_bonus = _consume_stat_token(chara.crt, 9, 9, 0)
	chara.crt.x = crt_bonus[1].x
	chara.buff_container._update_crt_tokens(chara.crt.x)
	return crt_bonus[0]

static func _get_eva_bonus(chara: Character) -> float:
	if chara.eva.x == 0:
		return 0
	var eva_bonus = _consume_stat_token(chara.eva, 0.5, 0.75, 0)
	chara.eva.x = eva_bonus[1].x
	chara.buff_container._update_eva_tokens(chara.eva.x)
	return eva_bonus[0]
