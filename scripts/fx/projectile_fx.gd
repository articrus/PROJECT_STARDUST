extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 06-12-2025 / 06-12-2025
@onready var sprite = $Sprite2D
@export var texture = Texture

func _ready() -> void:
	sprite.texture = texture
