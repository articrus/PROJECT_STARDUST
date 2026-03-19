extends Node
class_name Dialogue_Parser
# Written By: Gianni Coladonato
# Date Created / Modified: 27-02-2026 / 18-03-2026

static func _get_player_quip_lines(player: enums.PLAYERS) -> Character_Quips:
	var quips: Character_Quips = Character_Quips.new()
	quips = _create_quips_from_json(JSON_Strings.player_quips[player])
	return quips

static func _get_two_character_dialogue(key: String) -> Character_Dialogue_Tree:
	var dialogue: Character_Dialogue_Tree = Character_Dialogue_Tree.new()
	dialogue = _create_two_char_from_json(JSON_Strings.two_char_dialogue[key])
	return dialogue

static func _create_quips_from_json(path: String) -> Character_Quips:
	var quips: Character_Quips = Character_Quips.new()
	var lines = _load_json_file(path)
	if lines != null:
		quips.battle_start = lines["B_START"]
		quips.crit_quotes = lines["CRIT"]
		quips.skip_quotes = lines["SKIP"]
		#quotes.XXX = lines["XXX]
	return quips

static func _create_two_char_from_json(path: String) -> Character_Dialogue_Tree:
	var dialogue: Character_Dialogue_Tree = Character_Dialogue_Tree.new()
	var tree = _load_json_file(path)
	if tree != null:
		dialogue.passive_dialogue = _json_array_to_lines(tree["PASSIVE"]) # Passive Dialogue Lines
	return dialogue

static func _json_array_to_lines(lines) -> Array[Dialogue_Collection]:
	var lines_collection: Array[Dialogue_Collection]
	for line in lines: 
			var collection: Dialogue_Collection = Dialogue_Collection.new()
			for text in line:
				var chatter: Dialogue_Line = Dialogue_Line.new()
				chatter.player_type = enums.STRING_TO_PLAYER[text[0]]
				chatter.text = text[1]
				collection.dialogue_lines.append(chatter)
			lines_collection.append(collection)
	return lines_collection

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

# Get the dialogue key from actors name
static func _generate_dialogue_key(actors) -> String:
	actors.sort()
	return str(enums.PLAYERS_STRING[actors[0]] + "_" + enums.PLAYERS_STRING[actors[1]])
