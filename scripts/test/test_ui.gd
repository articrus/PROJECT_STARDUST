extends Control

func _on_mana_add_pressed() -> void:
	ManaManager._add_mana(25.0)

func _on_mana_rem_pressed() -> void:
	ManaManager._remove_mana(25.0)

func _on_chat_button_pressed() -> void:
	Signalbus.temp_do_chatter.emit()
