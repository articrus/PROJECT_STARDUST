extends Node
class_name Player_Loader
# Written By: Gianni Coladonato
# Date Created / Modified: 16-04-2026 / 16-04-2026
static var player_paths = {
	enums.PLAYERS.RED: "res://characters/players/red_player.tscn",
	enums.PLAYERS.ORG: "res://characters/players/org_player.tscn",
	enums.PLAYERS.YLW: "res://characters/players/ylw_player.tscn",
	enums.PLAYERS.GRN: "res://characters/players/grn_player.tscn",
	enums.PLAYERS.BLU: "res://characters/players/blu_player.tscn",
	enums.PLAYERS.PUR: "res://characters/players/pur_player.tscn"
}

static func _load_player(player_type: enums.PLAYERS):
	return load(player_paths[player_type])

static var player_data_paths = { 
	enums.PLAYERS.RED: "res://characters/players/data/RED.tres",
	enums.PLAYERS.ORG: "res://characters/players/data/ORG.tres",
	enums.PLAYERS.YLW: "res://characters/players/data/YLW.tres",
	enums.PLAYERS.GRN: "res://characters/players/data/GRN.tres",
	enums.PLAYERS.BLU: "res://characters/players/data/BLU.tres",
	enums.PLAYERS.PUR: "res://characters/players/data/PUR.tres"
}

static func _load_player_data(player_type: enums.PLAYERS):
	return load(player_data_paths[player_type])
