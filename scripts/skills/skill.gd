extends Resource
class_name Skill
# Written By: Gianni Coladonato
# Date Created / Modified : 01-11-2025 / 25-04-2026
@export var skill_name: String = "Skill Name"
@export var skill_description: String = "Skill Description"
@export var cost: int = 0
@export var skill_target: enums.TARGET
@export var skill_effects: Array[Skill_Effect] # The list of effects for a specified skill
@export var skill_anim_index: int = 0
@export var skill_fx: PackedScene

func _execute_skill(actor: Node2D, target: Node2D):
	for effect in skill_effects: # Apply Effects
		effect._apply_effect(actor, target)
	if skill_fx: # Display effects
		VfxManager._spawn_hit_effect(skill_fx, target)
	Signalbus.call_deferred("emit_signal", "skill_finished")
