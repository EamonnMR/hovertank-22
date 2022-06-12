extends Spatial

class_name WeaponSlot

export var primary: bool # Primary or secondary
var special_weapons = []
var stored_default_weapon: Node
var iff_profile = null

func get_weapon() -> Weapon:
	for child in get_children():
		if child is Weapon:
			return child
	return null

func has_weapon() -> bool:
	return get_weapon() != null

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
		stored_default_weapon.init(iff_profile)
	if not primary:
		for special_weapon_id in range(len(Client.SPECIAL_WEAPONS)):
			var special_weapon_data = Client.SPECIAL_WEAPONS[special_weapon_id]
			var weapon = special_weapon_data.scene.instance()
			weapon.init(iff_profile, special_weapon_id)
			special_weapons.append(weapon)
	
	if stored_default_weapon:
		stored_default_weapon.init(iff_profile)
	
	for weapon in special_weapons + [stored_default_weapon]:
		if weapon:
			weapon.init(iff_profile)
		
func select_special_weapon(special_weapon_id):
	var old_wep = get_weapon()
	remove_child(get_weapon())
	add_child(special_weapons[special_weapon_id])
	# TODO: Nifty animation of some kind
	var new_wep = get_weapon()
	assert(get_weapon() != old_wep)
	print("New wep: ", str(new_wep), " Old Wep: ", str(old_wep))
	
func return_default_weapon():
	remove_child(get_weapon())
	if stored_default_weapon:
		add_child(stored_default_weapon)
