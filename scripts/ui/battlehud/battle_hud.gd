extends Control
# Written By: Gianni Coladonato
# Date Created / Modified: 07-10-2025 / 22-03-2026
@onready var option_buttons = $BottomBorder/PlayerButtons
@onready var player_btns := {
	"Attack": $BottomBorder/PlayerButtons/Attack,
	"Skill": $BottomBorder/PlayerButtons/Skill,
	"Move": $BottomBorder/PlayerButtons/Move,
	"Item": $BottomBorder/PlayerButtons/Item,
	"Help": $BottomBorder/PlayerButtons/Help,
	"Skip": $BottomBorder/PlayerButtons/Skip
}
@onready var profile_box = $Border/ProfileBox
var profile_ref = [] # Save playertype for use later
@onready var profile_texture: PackedScene = preload("res://sprites/ui/profiles/profile.tscn")
@onready var mana_bar = $Border/ManaMeter
@onready var skill_buttons = $BottomBorder/SkillContainer
@onready var skill_btn: PackedScene = preload("res://ui/skill_button.tscn")
@onready var desc_box = $BottomBorder/DescriptionBox

func _ready() -> void:
	_bind_option_buttons()
	_toggle_buttons_lists(true, false)
	Signalbus.mana_changed.connect(_set_mana)
	ManaManager._add_mana(0)

func _bind_option_buttons() -> void:
	player_btns["Attack"].pressed.connect(_on_option_pressed.bind(enums.OPTION.ATTACK))
	player_btns["Skill"].pressed.connect(_on_option_pressed.bind(enums.OPTION.SKILL))
	player_btns["Item"].pressed.connect(_on_option_pressed.bind(enums.OPTION.ITEM))
	player_btns["Move"].pressed.connect(_on_option_pressed.bind(enums.OPTION.MOVE))
	player_btns["Help"].pressed.connect(_on_option_pressed.bind(enums.OPTION.HELP))
	player_btns["Skip"].pressed.connect(_on_option_pressed.bind(enums.OPTION.SKIP))

func _toggle_buttons_lists(options: bool, skill: bool) -> void:
	option_buttons.visible = options
	if !skill:
		_clear_skill_buttons()
	skill_buttons.visible = skill
	_grab_button_focus()

func _set_mana(amount: float) -> void:
	mana_bar._update_mp_bar(amount)

func _on_option_pressed(option: enums.OPTION) -> void:
	match option:
		enums.OPTION.ATTACK:
			Signalbus.attack_selected.emit()
		enums.OPTION.SKILL:
			Signalbus.skill_selected.emit()
			_toggle_buttons_lists(false, true)
		enums.OPTION.ITEM:
			print("NOT YET IMPLEMENTED")
		enums.OPTION.MOVE:
			Signalbus.move_selected.emit()
		enums.OPTION.HELP:
			print("NOT YET IMPLEMENTED")
		enums.OPTION.SKIP:
			Signalbus.skipped_selected.emit()

# Spawn all necessary buttons for the character's skills
func _populate_skill_container(actor: Character) -> void:
	_clear_skill_buttons()
	# Add new buttons
	for skill in actor.skill_list:
		var new_button = skill_btn.instantiate()
		new_button._set_up_button(skill)
		skill_buttons.add_child(new_button)
		new_button.disabled = ManaManager.mana.x < skill.cost

# Add profile shots to box
func _populate_profile_container(party) -> void:
	for child in profile_box.get_children():
		child.queue_free()
	for player in party.get_children():
		var new_box = profile_texture.instantiate()
		profile_ref.append(player.player_type)
		match player.player_type:
			enums.PLAYERS.RED:
				new_box.texture = load("res://sprites/ui/profiles/PLF_RED.tres")
			enums.PLAYERS.GRN:
				new_box.texture = load("res://sprites/ui/profiles/PLF_GRN.tres")
			enums.PLAYERS.BLU:
				new_box.texture = load("res://sprites/ui/profiles/PLF_BLU.tres")
		profile_box.add_child(new_box)

func _clear_skill_buttons() -> void:
	for child in skill_buttons.get_children():
		child.queue_free()

func _set_current_turn_profile(current_player) -> void:
	var index = 0
	for profile in profile_box.get_children():
		if current_player.player_type != profile_ref[index]:
			profile.modulate = Color.DARK_GRAY
		else:
			profile.modulate = Color.WHITE
		index += 1

func _grab_button_focus() -> void:
	if(option_buttons.visible):
		player_btns["Attack"].grab_focus()
	elif skill_buttons.get_child_count() > 0:
		skill_buttons.get_child(0).grab_focus()

func _get_attack_option_damage_text(chara: Character) -> String:
	var to_return = ""
	# Print Target
	match chara.char_attack.skill_target:
		enums.TARGET.ENEMY:
			to_return += "Single Target, "
	# Get Damage
	var dmg_boost = Token_Utils._get_atk_bonus_for_display(chara)
	var dmg_type = 0
	if chara.rank < 2:
		dmg_type = chara.abilities.x
	else:
		dmg_type = chara.abilities.y
	to_return += str(int(ceil(dmg_type / 2.0) * dmg_boost)) + "-" + str(int(dmg_type * dmg_boost))
	return to_return

# Prepare all the option text/hover ui
func _set_option_name_and_descriptions(actor: Character) -> void:
	player_btns["Attack"]._set_attack_option_text(actor.char_attack, actor.rank, _get_attack_option_damage_text(actor))
	# Do this again for help and skip, since they'll have different effects
