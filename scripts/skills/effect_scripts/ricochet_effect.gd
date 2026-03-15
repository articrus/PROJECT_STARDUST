extends Skill_Effect
class_name Ricochet_Effect

@export var damage_roll: int = 6

# Deal a big chunk of damage to a target
func _apply_effect(actor: Node2D, target: Node2D):
	var damage = int(randi_range(ceil(damage_roll / 2.0), damage_roll) + (actor.char_stats.abilities.z / 4.0))
	var falloff = 1.0 # Deals less damage for each target
	for enemy in target.get_children():
		if enemy.char_stats.is_alive:
			enemy.char_stats._hurt(int(damage * falloff))
			DamageNumbers._display_damage(enemy, damage, false)
			falloff -= 0.25
