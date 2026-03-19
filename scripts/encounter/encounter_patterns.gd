extends Node
class_name Encounter_Patterns
# Written By: Gianni Coladonato
# Date Created / Modified : 19-03-2026 / 19-03-2026

# Temporary design for now, flush out with different monster types as game expands
static func _standard_patterns(pattern: int) -> Array[enums.MONSTERS]:
	match pattern:
		0:
			return [enums.MONSTERS.SLIME, enums.MONSTERS.SLIME, enums.MONSTERS.SLIME]
		1:
			return [enums.MONSTERS.SLIME, enums.MONSTERS.SLIME, enums.MONSTERS.SLIME, enums.MONSTERS.SLIME]
		2:
			return [enums.MONSTERS.SLIME, enums.MONSTERS.SLIME, enums.MONSTERS.NYMPH]
		3:
			return [enums.MONSTERS.SLIME, enums.MONSTERS.SLIME, enums.MONSTERS.SLIME, enums.MONSTERS.NYMPH]
		_:
			return []
