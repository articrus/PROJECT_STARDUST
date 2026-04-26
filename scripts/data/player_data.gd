extends Resource
class_name Player_Data
# Written By: Gianni Coladonato
# Date Created / Modified : 10-11-2025 / 25-04-2025
@export var hp: Vector2i = Vector2i(0,0)
@export var abilities: Vector2i = Vector2i.ZERO
@export var skill_list: Array[Skill]
@export var char_attack: Skill

# Save / transfer player data
func _save_player_data(actor: Character):
	hp = actor.hp
	abilities = actor.abilities
	skill_list = actor.skill_list
	char_attack = actor.char_attack

# Load player data into a newly instantiated scene
func _load_player_data(actor: Character):
	actor.hp = hp
	actor.abilities = abilities
	actor.skill_list = skill_list
	actor.char_attack = char_attack
