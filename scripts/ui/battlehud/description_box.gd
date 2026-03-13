extends VBoxContainer
# Written By: Gianni Coladonato
# Date Created/Modificed: Sometime in 2025 | 13-03-2026
@onready var option_name = $SkillName
@onready var option_dmg = $Damage
@onready var option_desc = $Description

func _ready() -> void:
	Signalbus.display_option_info.connect(_display_option_data)
	Signalbus.clear_option_text.connect(_clear_text)
	_clear_text();
	option_dmg.visible = false

# Displays the option data, ignoring the damage text if it's empty
func _display_option_data(name_text: String, desc_text: String, dmg_text := "") -> void:
	option_name.text = name_text
	option_desc.text = desc_text
	if !dmg_text.is_empty():
		option_dmg.visible = true
		option_dmg.text = dmg_text
	else:
		option_dmg.visible = false

# Clears the text
func _clear_text() -> void:
	option_name.text = "";
	option_desc.text = "";
	option_dmg.text = "";
