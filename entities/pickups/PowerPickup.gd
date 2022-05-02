extends Pickup

var energy_amt = 20

func do_pickup_effect(body):
	body.get_node("Energy").add_energy(20)

func can_pickup(body) -> bool:
	return body and body.has_method("is_player") and body.is_player() and body.has_node("Energy") and not body.get_node("Energy").is_full()
