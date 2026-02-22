extends Node

@onready var damage_label : PackedScene = preload("res://ui/text/damage_label.tscn")

# To reduce redundancy of instantiation/assignment
func _init_damage_label(target: Node2D):
	var dmg_label = damage_label.instantiate()
	dmg_label.scale = Vector2(0.15, 0.15)
	dmg_label.global_position = target.essentials._get_dmg_pos()
	dmg_label.z_index = 5
	return dmg_label

func _display_damage(target: Node2D, value: int, is_crit: bool):
	var dmg_label = _init_damage_label(target)
	add_child(dmg_label)
	dmg_label._prepare_damage_text(str(value), is_crit)

func _display_miss(target: Node2D):
	var dmg_label = _init_damage_label(target)
	add_child(dmg_label)
	dmg_label._prepare_damage_text("MISS", false)

func _display_healing(target: Node2D, value: int):
	var dmg_label = _init_damage_label(target)
	add_child(dmg_label)
	dmg_label._prepare_heal_text(value)
