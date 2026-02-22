extends Control
# Written By: Gianni Coladonato
# Date Created / Modified: 12-02-2026 / 12-02-2026
@onready var top = $TopBar
@onready var bottom = $BottomBar
# Export vars
@export var top_time: float = 0.2
@export var top_delay: float = 0
@export var bottom_time: float = 0.4
@export var bottom_delay: float = 0.1

func _inital_values(amount: float) -> void:
	top.value = amount
	bottom.value = amount

func _update_mp_bar(amount: float) -> void:
	if amount > top.value:
		_mp_bar_tween(top, amount, bottom_time, bottom_delay)
		_mp_bar_tween(bottom, amount, top_time, top_delay)
	else:
		_mp_bar_tween(top, amount, top_time, top_delay)
		_mp_bar_tween(bottom, amount, bottom_time, bottom_delay)

func _mp_bar_tween(bar: ProgressBar, value: float, length: float, delay: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", value, length).set_delay(delay)
