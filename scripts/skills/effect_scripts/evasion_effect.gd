extends Skill_Effect
class_name Evasion_Effect

@export var buff_stage: int = 0

# Buff the target's eva modifier by the buff_stage amount
func _apply_effect(_actor: Node2D, target: Node2D):
	Token_Utils._eva_buff(target.char_stats, buff_stage)
