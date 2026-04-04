extends BoxContainer
# Written By: Gianni Coladonato
# Date Created/Modificed: 11-11-2025 | 03-04-2026
# Tokens with no counters
@onready var mark = $Mark
@onready var stun = $Stun
# Tokens of the same stat with counters
@onready var stat_tokens := {
	"ATK": {
		"buff": $Attack,
		"big_buff": $BigAttack,
		"debuff": $BadAttack
	},
	"DEF": {
		"buff": $Defense,
		"big_buff": $BigDefense,
		"debuff": $BadDefense
	},
	"EVA": {
		"buff": $Evasion,
		"big_buff": $BigEvasion,
		"debuff": null
	}
}
# Tokens with counters
@onready var single_tokens := {
	"CRT": { # Crit / Lucky
		"token": $Lucky
	},
	"BLD": { # Blind
		"token": $Lucky
	}
}
#@onready var class_token = $Class

func _ready() -> void:
	for token in self.get_children():
		token.visible = false 

# If character is a player, set it as mark, else as combo token
func _set_character_tokens(is_player: bool) -> void:
	mark._set_mark_or_combo(is_player)

# Sets the class token of the texture
#func _set_class_token(texture: AtlasTexture):
	#class_token.texture = texture

func _toggle_mark(toggle: bool) -> void:
	mark.visible = toggle

func _toggle_stun(toggle: bool) -> void:
	stun.visible = toggle

# For tokens like attack and defense
func _update_multi_token_stat(stat_name: String, value: float) -> void:
	if !stat_tokens.has(stat_name):
		print("ERROR: INVALID TOKEN")
		return
	var tokens = stat_tokens[stat_name]
	# Reset all tokens for this stat
	tokens.buff.visible = false
	tokens.big_buff.visible = false
	if is_instance_valid(tokens.debuff):
		tokens.debuff.visible = false
	# Positive Value
	if value > 0: 
		var small_buffs = int(fmod(value, 10))
		var big_buffs = int(value / 10)
		# Setting visibility of main tokens
		tokens.buff.visible = small_buffs > 0
		tokens.big_buff.visible = big_buffs > 0
		# Enabling additional counters
		if tokens.buff.visible:
			tokens.buff.counter._toggle_additional_counters(small_buffs)
		if tokens.big_buff.visible and tokens.big_buff.counter:
			tokens.big_buff.counter._toggle_additional_counters(big_buffs)
	elif value < 0 and is_instance_valid(tokens.debuff):
		var abs_value = abs(value)
		# Set visibility of main token
		tokens.debuff.visible = true
		# Set visibility of counters
		if tokens.debuff.counter:
			tokens.debuff.counter._toggle_additional_counters(abs_value)

# For tokens like crit, blind, and class
func _update_single_token_stat(stat_name: String, value: int) -> void:
	if !single_tokens.has(stat_name):
		print("ERROR: INVALID TOKEN")
		return
	var token_icon = single_tokens[stat_name]
	token_icon.token.visible = false
	
	if value > 0:
		token_icon.token.visible = true
		if token_icon.token.counter:
			if value - 1 <= 0:
				token_icon.token.counter._toggle_additional_counters(0)
			else:
				token_icon.token.counter._toggle_additional_counters(value - 1)

# ---Methods for easier calling--- #
# Attack Tokens
func _update_atk_tokens(value: float) -> void:
	_update_multi_token_stat("ATK", value)
# Defense Tokens
func _update_def_tokens(value: float) -> void:
	_update_multi_token_stat("DEF", value)
# Crit Token
func _update_crt_tokens(value: int) -> void:
	_update_single_token_stat("CRT", value)
# Evasion Token
func _update_eva_tokens(value: int) -> void:
	_update_multi_token_stat("EVA", value)
