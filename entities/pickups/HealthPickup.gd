extends Pickup

var HEAL_AMOUNT = 10

func do_pickup_effect(body):
	body.get_node("Health").heal(10)
		
func can_pickup(body) -> bool:
	var health = body.get_node("Health")
	if health:
		return health.can_heal()
	return false
