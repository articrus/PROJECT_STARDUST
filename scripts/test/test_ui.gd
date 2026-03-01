extends Control

func _on_mana_add_pressed() -> void:
	ManaManager._add_mana(25.0)

func _on_mana_rem_pressed() -> void:
	ManaManager._remove_mana(25.0)

func _on_chat_button_pressed() -> void:
	Signalbus.temp_do_chatter.emit()

func _on_quip_button_pressed() -> void:
	var quips: Character_Quips = Dialogue_Parser._get_player_quip_lines(enums.PLAYERS.RED)
	print(quips.battle_start)
	print(quips.crit_quotes)
	print(quips.skip_quotes)
	quips = Dialogue_Parser._get_player_quip_lines(enums.PLAYERS.GRN)
	print(quips.battle_start)
	print(quips.crit_quotes)
	print(quips.skip_quotes)
	quips = Dialogue_Parser._get_player_quip_lines(enums.PLAYERS.BLU)
	print(quips.battle_start)
	print(quips.crit_quotes)
	print(quips.skip_quotes)
