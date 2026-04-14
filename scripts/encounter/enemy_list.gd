extends Node
class_name Enemy_List
# Written By: Gianni Coladonato
# Date Created / Modified: 19-03-2026 / 13-04-2026
static var paths = {
	enums.MONSTERS.SLIME: "res://characters/enemies/slime.tscn",
	enums.MONSTERS.NYMPH: "res://characters/enemies/nymph.tscn"
}
static var monster_cache: Dictionary = {}

static func _get_monster(monster: enums.MONSTERS) -> PackedScene: # Returns the monster scene
	if !monster_cache.has(monster):
		assert(ResourceLoader.exists(paths[monster]), "ERROR: MISSING SCENE")
		monster_cache[monster] = load(paths[monster])
	return monster_cache[monster]

static func _load_cache(monsters: Array[enums.MONSTERS]) -> void: # Preload the cache at start of level for faster access
	for monster in monsters:
		monster_cache[monster] = load(paths[monster])

static func _clear_cache() -> void: # Empties the cache
	monster_cache.clear()
