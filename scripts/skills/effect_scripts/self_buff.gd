extends Skill_Effect
class_name Self_Buff
# This class/effect is used for skills where the skill is supposed to target an 
# enemy while buffing themselves, since the current set-up doesn't really work with that
@export var atk_buff: float = 0.0
@export var def_buff: float = 0.0
@export var crit_buff: int = 0

func _apply_effect(actor: Node2D, _target: Node2D):
	Token_Utils._atk_buff(actor.char_stats, atk_buff)
	Token_Utils._def_buff(actor.char_stats, def_buff)
