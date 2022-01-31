extends Pickup

func do_pickup_effect(body):
	body.get_node("Energy")

func can_pickup(body: Vehicle) -> bool:
	return body.has_method("is_player") and body.is_player()
