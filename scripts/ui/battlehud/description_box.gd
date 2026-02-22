extends VBoxContainer

@onready var option_name = $SkillName
@onready var option_dmg = $Damage
@onready var option_desc = $Description

func _ready() -> void:
	Signalbus.display_option_info.connect(_display_option_data)
	option_name.text = ""
	option_dmg.text = ""
	option_dmg.visible = false
	option_desc.text = ""

func _display_option_data(name_text: String, desc_text: String, dmg_text := "") -> void:
	option_name.text = name_text
	option_desc.text = desc_text
	if !dmg_text.is_empty():
		option_dmg.visible = true
		option_dmg.text = dmg_text
	else:
		option_dmg.visible = false
