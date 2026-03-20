extends Control
# Written By: Gianni Coladonato
# Date Created / Modified: 20-03-2026 / 20-03-2026
@onready var menu_buttons:= {
	"CONTINUE": $HBoxContainer/ContinueButton,
	"PLAY": $HBoxContainer/PlayButton,
	"BONUS": $HBoxContainer/BonusButton,
	"SETTINGS": $HBoxContainer/SettingsButton,
	"CREDITS": $HBoxContainer/CreditsButton,
	"QUIT": $HBoxContainer/QuitButton
}
@onready var settings_panel = $Settings

func _ready() -> void:
	settings_panel.visible = false

func _on_play_button_pressed() -> void:
	pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	settings_panel.visible = true

func _on_quit_button_pressed() -> void:
	#Add some animation or flair before quitting/saving progress?
	get_tree().quit()
