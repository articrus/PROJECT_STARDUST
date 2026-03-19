extends Node
class_name Encounter_Generator
# Written By: Gianni Coladonato
# Date Created / Modified : 19-03-2026 / 19-03-2026

static func _generate_encounter():
	pass
	# Have difficulty/type encounters

static func _generate_standard_encounter(pattern: int) -> Encounter_Data:
	var new_data:= Encounter_Data.new()
	new_data.enemies = Encounter_Patterns._standard_patterns(pattern)
	return new_data

static func _generate_miniboss_encounter(_boss_index: int) -> Encounter_Data:
	var new_data:= Encounter_Data.new()
	return new_data

static func _generate_boss_encounter(_boss_index: int) -> Encounter_Data:
	var new_data:= Encounter_Data.new()
	return new_data

static func _generate_silly_encounter(_silly_index: int) -> Encounter_Data:
	var new_data:= Encounter_Data.new()
	return new_data
