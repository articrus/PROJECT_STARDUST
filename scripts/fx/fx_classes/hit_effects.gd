extends Node

@onready var player_ranged_effects := {
	enums.PLAYERS.RED: load("res://sprites/players/projectiles/red_rtk.png"),
	enums.PLAYERS.BLU: load("res://sprites/players/projectiles/blu_rtk.png"),
	enums.PLAYERS.GRN: load("res://sprites/players/projectiles/grn_rtk.png")
}
