extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 07-12-2025 / 07-12-2025
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D #TODO Change sprite dependant on character
# Custom Hit Effect
@export var custom_sprite: Texture

func _ready() -> void:
	sprite.texture = custom_sprite
	anim_player.play("hit_fx")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	self.queue_free()
