extends Resource
class_name Skill
# Written By: Gianni Coladonato
# Date Created / Modified : 01-11-2025 / 29-12-2025

@export var skill_name: String = "Skill Name"
@export var skill_description: String = "Skill Description"
@export var cost: int = 0
@export var skill_target: enums.TARGET
@export var skill_effects: Array[Skill_Effect] # The list of effects for a specified skill
@export var skill_fx: PackedScene

func _execute_skill(actor: Node2D, target: Node2D):
	# Apply Effects
	for effect in skill_effects:
		effect._apply_effect(actor, target)
	# Display effects
	if skill_fx:
		VfxManager._spawn_hit_effect(skill_fx, target)
	Signalbus.call_deferred("emit_signal", "skill_finished")
