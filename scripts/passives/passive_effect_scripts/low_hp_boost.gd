extends Passive_Effect
class_name Low_HP_Boost

# The lower the hp the higher the boost is (1.0 - 1.99)
func _apply_boost(actor: Character):
	return 1 - (actor.hp.x / float(actor.hp.y))
