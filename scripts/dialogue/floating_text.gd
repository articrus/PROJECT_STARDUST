extends Node2D
# Written By: Gianni Coladonato
# Date Created / Modified: 20-11-2025 / 10-02-2026
@onready var label = $Label
var time_elapsed: float
@export var max_time: float = 1.0
@export var typing_speed : float = 60
var typing_time : float
var label_settings

func _ready() -> void:
	time_elapsed = 0
	label_settings = LabelSettings.new()
	label.label_settings = label_settings
	label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	label.label_settings.font_size = 48
	label.pivot_offset = label.size / 2

func _display_text(new_text : String, voice, color := Color.WHITE):
	AudioManager._play_voice_sfx(voice)
	label.text = new_text
	label.label_settings.font_color = color
	label.visible_characters = 0
	typing_time = 0
	while label.visible_characters < label.get_total_character_count():
		typing_time += get_process_delta_time()
		label.visible_characters = typing_speed * typing_time as int
		await get_tree().process_frame
	AudioManager._stop_voice_sfx()

func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed >= max_time:
		time_elapsed = 0
		Signalbus.text_finished.emit()
		self.queue_free()
