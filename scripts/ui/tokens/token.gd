extends TextureRect
# Written By: Gianni Coladonato
# Date Created / Modified : 23-10-2025 / 09-12-2025
@onready var counter = $CounterContainer
@export var token_name: String
@export var token_description: String

# If the token is mark, adjust it, else set it as combo token
func _set_mark_or_combo(is_mark: bool) -> void:
	if is_mark:
		token_name = "Mark"
		token_description = "Enemies are more likely to target this character"
	else:
		token_name = "Combo"
		token_description = "Attacks trigger additional effects"
		self.texture = load("res://ui/textures/tokens/combo.tres")

func _on_mouse_entered() -> void:
	Signalbus.display_option_info.emit(token_name, token_description, "")

func _on_mouse_exited() -> void:
	Signalbus.display_option_info.emit("", "", "")
