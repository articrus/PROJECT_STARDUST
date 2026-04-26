extends Skill_Effect
class_name Attack_Effect
# Written By: Gianni Coladonato
# Date Created / Modified: Sometime in 2025 / 25-04-2026
# Additonal Effects
@export var additional_effects_self: Array[Skill_Effect]
@export var additional_effects_enemy: Array[Skill_Effect]
@export var combo_damage_boost: float = 1.0
@export var can_combo: bool = false
#@export var combo_crit_boost: int = 0
# Attack Effects
@export var hit_fx: PackedScene

func _apply_effect(actor: Node2D, target: Node2D):
	# Get the attack damage
	var damage = actor.char_stats._attack_damage()
	#var crit_boost = 0
	if target.char_stats.is_marked && can_combo:
		damage *= combo_damage_boost
		#crit_boost += combo_crit_boost
	var crit = actor.char_stats._is_crit()
	if crit:
		DialogueManager._crit_quip(actor)
		damage *= 1.5
	# Check if target dodges
	if target.char_stats._does_actor_dodge():
		DamageNumbers._display_miss(target)
		Signalbus.call_deferred("emit_signal", "skill_finished")
		return
	# Target doesn't dodge, proceed with attack damage
	var reduction = target.char_stats._damage_reduction(damage)
	target.char_stats._hurt(reduction)
	if target.char_stats.is_alive:
		target.animation_node._hit()
	# Apply combo effects (if combo)
	if target.char_stats.is_marked && can_combo:
		for effect in additional_effects_self:
			effect._apply_effect(actor, actor)
		for effect in additional_effects_enemy:
			effect._apply_effect(actor, target)
		target.char_stats._remove_mark()
	# Display FX
	DamageNumbers._display_damage(target, reduction, crit)
	if hit_fx:
		VfxManager._spawn_hit_effect(hit_fx, target)
	Signalbus.call_deferred("emit_signal", "skill_finished")
