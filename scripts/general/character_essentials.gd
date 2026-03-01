extends Node2D
class_name Character_Essentials
# Written By: Gianni Coladonato
# Date Created / Modified: Sometime in 2025 / 27-02-2026
@onready var dialogue_pos = $DialogueMarker
@onready var dmg_pos = $DamageMarker
@onready var hit_pos = $HitMarker
# Voice and Quips
@export var voice: AudioStream
@export var quips: Character_Quips
@export var text_color: Color

func _get_dmg_pos() -> Vector2:
	return dmg_pos.global_position

func _get_dialogue_pos() -> Vector2:
	return dialogue_pos.global_position

func _get_hit_pos() -> Vector2:
	return hit_pos.global_position

func _load_player_quips(pending_quips: Character_Quips) -> void:
	quips = pending_quips
