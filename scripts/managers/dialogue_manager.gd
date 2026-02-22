extends Node
# Written By: Gianni Coladonato
# Date Created / Modified: 20-11-2025 / 10-02-2026
@onready var dialogue_label: PackedScene = preload("res://ui/text/floating_text.tscn")
@onready var two_char_key = {
	"RED_GRN": preload("res://scripts/dialogue/two_character_lines/RED_GRN.tres"),
	"RED_BLU": preload("res://scripts/dialogue/two_character_lines/RED_BLU.tres"),
	"GRN_BLU": preload("res://scripts/dialogue/two_character_lines/GRN_BLU.tres")
}
func _display_dialogue(text: String, actor: Node2D) -> void:
	var text_box = dialogue_label.instantiate()
	text_box.scale = Vector2(0.1, 0.1)
	actor.add_child(text_box)
	text_box.global_position = actor.essentials._get_dialogue_pos() # Dialogue box position
	text_box._display_text(text, actor.essentials.voice, actor.essentials.quips.text_color)

func _two_chara_dialogue(actorA: Node2D, actorB: Node2D, key: String) -> void:
	var dialogue_lines = two_char_key[key]
	for line in dialogue_lines.passive_dialogue:
		if line.player_type == actorA.player_type:
			_display_dialogue(line.text, actorA)
		else:
			_display_dialogue(line.text, actorB)
		await Signalbus.text_finished

func _skip_quip(actor: Node2D) -> void:
	var text = actor.essentials.quips._get_skip_quote()
	_display_dialogue(text, actor)

func _crit_quip(actor: Node2D) -> void:
	var text = actor.essentials.quips._get_crit_quote()
	_display_dialogue(text, actor)
