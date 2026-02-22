extends Skill_Effect
class_name Heal_Effect

@export var heal_percentage: float = 1

# Heal a heal chunk of hp to a target
func _apply_effect(actor: Node2D, target: Node2D):
	var healing = int((actor.char_stats.abilities.z/2) + (target.char_stats.hp.y * heal_percentage))
	target.char_stats._heal(healing)
	DamageNumbers._display_healing(target, healing)
