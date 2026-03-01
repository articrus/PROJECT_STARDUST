extends Resource
class_name Character_Quips
# An array of skip quotes
@export var battle_start: = []
@export var skip_quotes: = []
@export var crit_quotes: = []

# Returns a random skip quote
func _get_skip_quote() -> String:
	var rand = randi_range(0, skip_quotes.size()-1)
	return skip_quotes[rand]

# Returns a random crit quote
func _get_crit_quote() -> String:
	var rand = randi_range(0, crit_quotes.size()-1)
	return crit_quotes[rand]

# Returns a random battle start quote
func _get_battle_start_quote() -> String:
	var rand = randi_range(0, battle_start.size()-1)
	return battle_start[rand]
