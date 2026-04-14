extends CanvasLayer
# Written By: Gianni Coladonato
# Date Created / Modified: 13-04-2026 / 13-04-2026
@onready var settings_panel = $Settings

func _ready() -> void:
	Signalbus.pause.connect(_toggle_pause)

func _toggle_pause(toggle: bool) -> void:
	settings_panel.visible = toggle
