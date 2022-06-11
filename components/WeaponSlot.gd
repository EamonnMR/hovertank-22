extends Spatial

class_name WeaponSlot

export var primary: bool # Primary or secondary
var special_weapons = []
var stored_default_weapon: Node
var iff_profile = null

func get_weapon() -> Weapon:
	return get_children()[0]

func has_weapon() -> bool:
	return get_children().size() == 1

func init(iff_profile):
	self.iff_profile = iff_profile

func _ready():
	# Inefficient call, but _ready hasn't been called on the turret yet
	var parent = get_node("../../")._get_parent()
	var iff_profile = IffProfile.new(
		parent,
		parent.get_node("VehicleCore").faction,
		false
	)
	
	if has_weapon():
		stored_default_weapon = get_weapon()
	if not primary:
		for special_weapon_data in Client.SPECIAL_WEAPONS:
			special_weapons.append(special_weapon_data.scene.instance())
	
	for weapon in special_weapons + [stored_default_weapon]:
		if weapon:
			weapon.init(iff_profile)
		
func select_special_weapon(special_weapon_id):
	remove_child(get_weapon())
	add_child(special_weapons[special_weapon_id])
	# TODO: Nifty animation of some kind
	
func return_default_weapon():
	remove_child(get_weapon())
	if stored_default_weapon:
		add_child(stored_default_weapon)
