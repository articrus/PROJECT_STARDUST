extends Node
# Written By: Gianni Coladonato
# Date Created / Modified: 06-10-2025 / 13-04-2026
@onready var battle_scene = load("res://scenes/battle_scene.tscn")
# Player Scenes stored alongside enum keys
var player_templates: ={
	enums.PLAYERS.RED: load("res://characters/players/red_player.tscn"),
	#enums.PLAYERS.ORG: load("res://characters/players/org_player.tscn")
	#enums.PLAYERS.YLW: load("res://characters/players/ylw_player.tscn")
	enums.PLAYERS.GRN: load("res://characters/players/grn_player.tscn"),
	enums.PLAYERS.BLU: load("res://characters/players/blu_player.tscn")
	#enums.PLAYERS.PUR: load("res://characters/players/pur_player.tscn")
}
# Player Data stored alongside enum keys
var player_data_saves: ={
	enums.PLAYERS.RED: load("res://characters/players/data/RED.tres"),
	enums.PLAYERS.ORG: load("res://characters/players/data/ORG.tres"),
	enums.PLAYERS.YLW: load("res://characters/players/data/YLW.tres"),
	enums.PLAYERS.GRN: load("res://characters/players/data/GRN.tres"),
	enums.PLAYERS.BLU: load("res://characters/players/data/BLU.tres"),
	enums.PLAYERS.PUR: load("res://characters/players/data/PUR.tres")
}
@export var current_party: Array[enums.PLAYERS] = [enums.PLAYERS.RED, enums.PLAYERS.BLU, enums.PLAYERS.GRN]
var current_battle
var current_encounter: Encounter_Data
var is_in_battle 
var is_paused = false

func _ready() -> void:
	Signalbus.trigger_encounter.connect(_load_battle_scene)
	Signalbus.end_encounter.connect(_destroy_battle_scene)
	is_in_battle = false

# Called once the world is ready
func _on_world_ready():
	Signalbus.pass_party_to_load.emit(current_party)

func _load_battle_scene(encounter: Encounter_Data):
	if !is_in_battle:
		is_in_battle = true
		GlobalVariables.can_move = false
		current_battle = battle_scene.instantiate()
		get_tree().current_scene.visible = false
		current_encounter = encounter
		call_deferred("_add_battle_scene")

func _add_battle_scene():
	add_child(current_battle)
	await get_tree().process_frame
	current_battle._on_battle_scene_ready(current_encounter)

func _destroy_battle_scene():
	current_battle.queue_free()
	is_in_battle = false
	GlobalVariables.can_move = true
	get_tree().current_scene.visible = true
	Signalbus.refresh_player_data.emit()

func _on_pause():
	if is_paused:
		Signalbus.pause.emit(true)
		GlobalVariables.can_move = false
		is_paused = false
	else:
		Signalbus.pause.emit(false)
		GlobalVariables.can_move = true
		is_paused = true

func _get_player_data(player_type: enums.PLAYERS):
	return player_data_saves[player_type]

func _save_player_data_from_node(player_node):
	var data = player_data_saves[player_node.player_type]
	data._save_player_data(player_node.char_stats)
