extends Control
# Written By: Gianni Coladonato
# Date Created / Modified: 20-03-2026 / 08-04-2026
@onready var volume_sliders = {
	"MASTER": $Panel/VBoxContainer/Master/MasterVol,
	"MUSIC": $Panel/VBoxContainer/Music/MasterVol,
	"SFX": $Panel/VBoxContainer/SFX/MasterVol,
	"VOICES": $Panel/VBoxContainer/Voices/MasterVol
}

func _ready() -> void:
	_bind_volume_sliders()

func _on_back_button_pressed() -> void:
	self.visible = false

func _bind_volume_sliders() -> void:
	volume_sliders["MASTER"].value_changed.connect(_on_volume_changed.bind(enums.VOL_BUSSES.MASTER))
	volume_sliders["MUSIC"].value_changed.connect(_on_volume_changed.bind(enums.VOL_BUSSES.MUSIC))
	volume_sliders["SFX"].value_changed.connect(_on_volume_changed.bind(enums.VOL_BUSSES.SFX))
	volume_sliders["VOICES"].value_changed.connect(_on_volume_changed.bind(enums.VOL_BUSSES.VOICE))

func _on_volume_changed(bus: enums.VOL_BUSSES, value: float) -> void:
	AudioManager._change_bus_vol(bus, value)
