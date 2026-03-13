extends Button
# Written By: Gianni Coladonato
# Date Created / Modified : 05-11-2025 / 13-03-2026
var option_skill: Skill
var option_name: String
var option_dmg: String
var option_desc: String

# Init the button name and other things
func _set_up_button(skill: Skill) -> void:
	option_skill = skill
	self.text = skill.skill_name 
	_set_skill_option_text(skill)

func _set_skill_option_text(skill: Skill) -> void:
	option_name = skill.skill_name
	option_desc = skill.skill_description
	var damage_text = ""
	damage_text += (str(skill.cost) + "% Mana, ")
	# Get Skill Target
	match skill.skill_target:
		enums.TARGET.ENEMY:
			damage_text += "Single Target"
		enums.TARGET.ALL_ENEMIES:
			damage_text += "All Enemies"
		enums.TARGET.ALLY:
			damage_text += "Ally Target"
		enums.TARGET.ALL_ALLIES:
			damage_text += "All Allies"
		enums.TARGET.SELF:
			damage_text += "Self"
	# Set Damage/Healing text
	var skill_main = skill.skill_effects[0]
	if skill_main is Damage_Effect or skill_main is Damage_All_Effect:
		damage_text += (", " + str(int(ceil(skill_main.damage_roll / 2.0))) + "-" +str(skill_main.damage_roll) + " Damage")
	elif skill_main is Heal_Effect or skill_main is Heal_All_Effect:
		damage_text += (", " + str(skill_main.heal_percentage) + " HP")
	option_dmg = damage_text

# When pressed, emit the pressed signal and the index of the selected skill
func _on_pressed() -> void:
	Signalbus.skill_button_pressed.emit(option_skill)

func _on_mouse_entered() -> void:
	Signalbus.display_option_info.emit(option_name, option_desc, option_dmg)

func _on_mouse_exited() -> void:
	Signalbus.clear_option_text.emit()
