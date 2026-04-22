extends Passive_Effect
class_name High_HP_Boost

# The higher the HP the greater the boost (1.0 - 1.99)
func _apply_boost(actor: Character):
	return (actor.hp.x / float(actor.hp.y))
