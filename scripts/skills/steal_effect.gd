extends Skill_Effect
class_name Steal_Effect

@export var steal_amount: int = 1

# Steal tokens from a target equal to the steal amount.
func _apply_effect(actor: Node2D, target: Node2D):
	# Steal Priority: ATK -> CRT -> EVA -> DEF -> HEAL
	var to_apply
	for i in range(steal_amount):
		# Stealing ATK
		if target.char_stats.atk.x > 0:
			to_apply = Token_Utils._consume_stat_token(target.char_stats.atk, 1, 1, 0)
			target.char_stats.atk = to_apply[1]
			target.actor_ui.buff_container._update_atk_tokens(target.char_stats.atk.x)
			Token_Utils._atk_buff(actor.char_stats, to_apply[0])
		# Stealing CRT
		elif target.char_stats.crt.x > 0:
			to_apply = Token_Utils._consume_stat_token(target.char_stats.crt, 1, 1, 0)
			target.char_stats.crt = to_apply[1]
			target.actor_ui.buff_container._update_crt_tokens(target.char_stats.crt.x)
			Token_Utils._crt_buff(actor.char_stats, to_apply[0])
		# Stealing DEF
		elif target.char_stats.def.x > 0:
			to_apply = Token_Utils._consume_stat_token(target.char_stats.def, 1, 1, 0)
			target.char_stats.def = to_apply[1]
			target.actor_ui.buff_container._update_def_tokens(target.char_stats.def.x)
			Token_Utils._def_buff(actor.char_stats, to_apply[0])
		# Heal a small amount
		else:
			actor.char_stats._heal(5)
			DamageNumbers._display_damage(actor, 5, false)
