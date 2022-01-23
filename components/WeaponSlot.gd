extends Spatial

class_name WeaponSlot

export var primary: bool # Primary or secondary

func get_weapon() -> Weapon:
	return get_children()[0]
