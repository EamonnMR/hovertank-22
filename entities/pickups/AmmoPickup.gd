extends Pickup

@export var special_id: int

func _ready():
	$Sprite3D.texture = Client.SPECIAL_WEAPONS[special_id].icon_tex

func do_pickup_effect(body):
	body.get_node("AmmoManager").add_special_ammo(special_id)

func can_pickup(body) -> bool:
	return body.has_node("AmmoManager") && body.get_node("AmmoManager").can_add_special_ammo(special_id)

