extends Skill_Effect
class_name Heal_All_Effect

@export var heal_percentage: float = 1.0

# Heal all friendly targets
func _apply_effect(actor: Node2D, target: Node2D):
	for ally in target.get_children(): # Pass Allies node
		var healing = int((actor.char_stats.abilities.z/2) + (ally.char_stats.hp.y * heal_percentage))
		ally.char_stats._heal(healing)
		DamageNumbers._display_healing(ally, healing)
