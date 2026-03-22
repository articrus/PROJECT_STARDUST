extends Control
# Written By: Gianni Coladonato
# Date Created / Modified: 12-02-2026 / 22-03-2026
@onready var top = $TopBar
@onready var bottom = $BottomBar
@onready var buff_container = $BuffContainer
# Export vars
@export var top_time: float = 0.2
@export var top_delay: float = 0
@export var bottom_time: float = 0.4
@export var bottom_delay: float = 0.1
# Character Details
var chara_name: String

func _inital_values(chara: Character) -> void:
	top.max_value = chara.hp.y
	top.value = chara.hp.x
	bottom.max_value = chara.hp.y
	bottom.value = chara.hp.x
	chara_name = chara.chara_name

func _update_hp_bar(hp: Vector2i) -> void:
	_hp_bar_tween(top, hp.x, top_time, top_delay)
	_hp_bar_tween(bottom, hp.x, bottom_time, bottom_delay)

func _hp_bar_tween(bar: ProgressBar, value: float, length: float, delay: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", value, length).set_delay(delay)

func _on_top_bar_mouse_entered() -> void:
	var hp_display = str(int(top.value)) + "/" + str(int(top.max_value)) 
	Signalbus.display_option_info.emit(chara_name, hp_display, "")

func _on_top_bar_mouse_exited() -> void:
	Signalbus.clear_option_text.emit()
