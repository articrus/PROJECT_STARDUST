@abstract
extends Resource
class_name Enemy_AI

@abstract func _make_decision(party_node: Node2D, enemies_node: Node2D) -> enums.ENEMY_CHOICE

@abstract func _end_of_turn_check() -> void
