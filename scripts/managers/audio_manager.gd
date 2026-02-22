extends Node

@onready var voice_player = $Voice

func _ready() -> void:
	pass

func _play_voice_sfx(voice_fx) -> void:
	voice_player.stream = voice_fx
	voice_player.play()

func _stop_voice_sfx() -> void:
	voice_player.stop()
