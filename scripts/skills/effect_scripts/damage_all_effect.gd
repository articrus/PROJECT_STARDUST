extends Skill_Effect
class_name Damage_All_Effect

@export var damage_roll: int = 6

# Damage all enemies (pass enemy node)
func _apply_effect(actor: Node2D, target: Node2D):
	var damage = int(randi_range(ceil(damage_roll / 2.0), damage_roll) + (actor.char_stats.abilities.z / 4.0))
	for enemy in target.get_children():
		if enemy.char_stats.is_alive:
			enemy.char_stats._hurt(damage)
			DamageNumbers._display_damage(enemy, damage, false)
