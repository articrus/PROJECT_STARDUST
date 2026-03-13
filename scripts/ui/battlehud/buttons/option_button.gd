extends Button

@export var option_name: String
@export var option_dmg: String
@export var option_desc: String

func _set_option_text(skill: Skill) -> void:
	option_name = skill.skill_name
	option_desc = skill.skill_description

func _set_attack_option_text(skill: Skill, rank: int, dmg_test: String) -> void:
	var attack_name = skill.skill_name
	var midpoint = attack_name.findn("/")
	if rank < 2: # Melee Attack
		option_name = "[b]" + attack_name.substr(0, midpoint) + "[/b]" + attack_name.substr(midpoint)
	else:
		option_name = attack_name.substr(0, midpoint) + "[b]" + attack_name.substr(midpoint) + "[/b]"
	option_desc = skill.skill_description
	option_dmg = dmg_test

func _on_mouse_entered() -> void:
	Signalbus.display_option_info.emit(option_name, option_desc, option_dmg)

func _on_mouse_exited() -> void:
	Signalbus.clear_option_text.emit()
