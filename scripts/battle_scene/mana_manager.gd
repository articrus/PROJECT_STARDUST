extends Node
# Written By: Gianni Coladonato
# Date Created / Modified: 04-02-2026 / 13-02-2026

@export var mana: Vector3i = Vector3i(55.0, 0, 100.0) # Current, Min, Max
const base_attack_mana = 5 
const base_defense_mana = 2

# Add mana (Max of 100, min of current amount (+0))
func _add_mana(amount: int) -> void:
	mana.x = mana.x + amount
	mana.x = clamp(mana.x, mana.x, mana.z)
	Signalbus.mana_changed.emit(mana.x)

# Remove mana (Min of 0, max of current amount (-0))
func _remove_mana(amount: int) -> void:
	mana.x = mana.x - amount
	mana.x = clamp(mana.x, mana.y, mana.x)
	Signalbus.mana_changed.emit(mana.x)

# Every party memeber that attacks gives a small mana bonus equal to their skill + 5
func _attack_mana_bonus(actor: Character) -> void:
	_add_mana(base_attack_mana + actor.abilities.y)

# When taking damage bonus, gain a small amount of mana
func _damage_mana_bonus(actor: Character) -> void:
	_add_mana(base_defense_mana + (actor.abilities.y/2))
