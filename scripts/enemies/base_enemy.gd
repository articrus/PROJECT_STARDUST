extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 20-10-2025 / 12-02-2026
@onready var char_stats = $Character
@onready var animation_node = $SimpleEnemy
@onready var actor_ui = $ActorUI
@onready var essentials = $CharacterEssentials
@export var enemy_brain: Enemy_AI

func _ready() -> void:
	char_stats.hp_changed.connect(actor_ui._update_hp_bar)
	actor_ui._inital_values(char_stats)
	animation_node.enemy_state = enums.ENEMY_STATE.IDLE
	char_stats.animation_node = animation_node
	actor_ui.buff_container._set_character_tokens(false)
	char_stats.buff_container = actor_ui.buff_container
