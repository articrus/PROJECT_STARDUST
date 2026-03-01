extends Node
class_name Dialogue_Parser
# Written By: Gianni Coladonato
# Date Created / Modified: 27-02-2026 / 27-02-2026

static func _get_player_quip_lines(player: enums.PLAYERS) -> Character_Quips:
	var quips: Character_Quips = Character_Quips.new()
	match player:
		enums.PLAYERS.RED:
			quips = _create_quips_from_json(JSON_Strings.red_quips_path)
		enums.PLAYERS.ORG:
			pass
		enums.PLAYERS.YLW:
			pass
		enums.PLAYERS.GRN:
			quips = _create_quips_from_json(JSON_Strings.grn_quips_path)
		enums.PLAYERS.BLU:
			quips = _create_quips_from_json(JSON_Strings.blu_quips_path)
		enums.PLAYERS.PUR:
			pass
	return quips

static func _create_quips_from_json(path: String) -> Character_Quips:
	var quips: Character_Quips = Character_Quips.new()
	var lines = _load_json_file(path)
	if lines != null:
		quips.battle_start = lines["B_START"]
		quips.crit_quotes = lines["CRIT"]
		quips.skip_quotes = lines["SKIP"]
	return quips

# Loads the JSON file 
static func _load_json_file(path: String):
	if FileAccess.file_exists(path):
		var data = FileAccess.open(path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data.get_as_text())
		if parsed_result is Dictionary:
			return parsed_result
		else: 
			print("ERROR: FILE IN INCORRECT FORMAT")
			return null
	else:
		print("ERROR: FILE NOT FOUND")
		return null
