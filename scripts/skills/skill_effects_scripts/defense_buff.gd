extends Skill_Effect
class_name Defense_Buff_Effect

@export var buff_stage: int = 0

# Deal a big chunk of damage to a target
func _apply_effect(_actor: Node2D, target: Node2D):
	Token_Utils._def_buff(target.char_stats, buff_stage)
