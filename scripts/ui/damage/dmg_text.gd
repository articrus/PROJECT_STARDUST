extends Node2D

@onready var label = $Label

var time_elapsed: float
@export var max_time: float = 0.65
var move_speed: Vector2 = Vector2(0, 0.05)
var move_x_max: float = 0.15
var move_x_min: float = -0.15
var scale_speed: Vector2 = Vector2(0.0005, 0.0005)
var label_settings

func _ready() -> void:
	time_elapsed = 0
	#move_speed.x = randf_range(move_x_min, move_x_max) # Randomize x velocity
	label_settings = LabelSettings.new()
	label.label_settings = label_settings
	label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	label.label_settings.font_size = 48
	label.pivot_offset = label.size / 2

func _prepare_damage_text(dmg: String, is_crit: bool):
	label.text = dmg
	if is_crit:
		label.label_settings.font_color = Color.CORAL

func _prepare_heal_text(hp: int):
	label.text = str(hp)
	label.label_settings.font_color = Color.WEB_GREEN

func _process(delta: float) -> void:
	time_elapsed += delta
	#position -= move_speed
	scale += scale_speed
	if(time_elapsed >= max_time):
		self.queue_free()
