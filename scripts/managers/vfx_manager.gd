extends Node
# Written By: Gianni Coladonato
# Date Created / Modified: 07-12-2025 / 29-12-2025

# Spawn a hit effect
func _spawn_hit_effect(effect, target: Node2D) -> void:
	var hit = effect.instantiate()
	hit.global_position = target.essentials._get_hit_pos()
	add_child(hit)
