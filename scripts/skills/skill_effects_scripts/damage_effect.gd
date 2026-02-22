extends Skill_Effect 
class_name Damage_Effect

@export var damage_roll: int = 6

# Deal a big chunk of damage to a target
func _apply_effect(actor: Node2D, target: Node2D):
	var damage = int(randi_range(ceil(damage_roll / 2.0), damage_roll) + (actor.char_stats.abilities.z / 4.0))
	target.char_stats._hurt(damage)
	DamageNumbers._display_damage(target, damage, false)
