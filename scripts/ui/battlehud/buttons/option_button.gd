extends Button
@export var option_name: String
@export var option_dmg: String
@export var option_desc: String

func _set_option_text(skill: Skill) -> void:
	option_name = skill.skill_name
	option_desc = skill.skill_description

func _set_skill_option_text(skill: Skill, dmg_test: String) -> void:
	option_name = skill.skill_name
	option_desc = skill.skill_description
	option_dmg = dmg_test

func _on_mouse_entered() -> void:
	Signalbus.display_option_info.emit(option_name, option_desc, option_dmg)

func _on_mouse_exited() -> void:
	Signalbus.clear_option_text.emit()

func _on_focus_entered() -> void:
	Signalbus.display_option_info.emit(option_name, option_desc, option_dmg)

func _on_focus_exited() -> void:
	Signalbus.clear_option_text.emit()
