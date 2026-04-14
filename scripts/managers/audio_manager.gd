extends Node

@onready var voice_player = $Voice
@onready var sfx_player = $SFX
@onready var music_player = $BackgroundMusic

func _ready() -> void:
	pass

func _play_voice_sfx(voice_fx) -> void:
	voice_player.stream = voice_fx
	voice_player.play()

func _stop_voice_sfx() -> void:
	voice_player.stop()

func _change_bus_vol(bus: enums.VOL_BUSSES, vol: float) -> void:
	AudioServer.set_bus_volume_db(bus, linear_to_db(vol))
