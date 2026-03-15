extends Skill_Effect
class_name Crit_Buff

@export var amount: int = 0

func _apply_effect(_actor: Node2D, target: Node2D):
	Token_Utils._crt_buff(target.char_stats, amount)
