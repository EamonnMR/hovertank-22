extends Node3D

@export var special_ammo_counts = []
var special_weapon_selected: bool
var current_special_weapon: int

signal ammo_count_changed(special_ammo_counts, current_special_weapon)

@onready var core = get_node("../VehicleCore")

func _ready():
	for i in sw_count():
		special_ammo_counts.push_back(1)
	connect("ammo_count_changed",Callable(Hud.ammo_widget,'update_ammo_count'))
	call_deferred("emit_signal", "ammo_count_changed", special_ammo_counts)
	
func consume_special_ammo(special_ammo_id: int) -> bool:
	if special_ammo_counts[special_ammo_id] == 0:
		call_deferred("switch_to_next_special_weapon")
		return false
	else:
		special_ammo_counts[special_ammo_id] -= 1
		emit_signal("ammo_count_changed", special_ammo_counts, current_special_weapon)
		return true

func can_add_special_ammo(special_id: int) -> bool:
	return special_ammo_counts[special_id] < Client.SPECIAL_WEAPONS[special_id].max_ammo

func switch_to_specific_special(special_id):
	if special_ammo_counts[special_id] > 0:
		for slot in core.get_node(core.turret_path).secondary_slots:
			slot.select_special_weapon(special_id)
		current_special_weapon = special_id
		special_weapon_selected = true
		emit_signal("ammo_count_changed", special_ammo_counts, current_special_weapon)
		return true
	else:
		return false

func switch_to_next_special_weapon():
	if not switch_to_specific_special(
		sw_mod(current_special_weapon + 1)
	):
		for i in range(1, sw_count()):
			var index = sw_mod(current_special_weapon + i)
			if switch_to_specific_special(index):
				break
		
		switch_to_default_weapon()
			
func switch_to_previous_special_weapon():
	if not switch_to_specific_special(
		sw_mod(current_special_weapon - 1)
	):
		for i in range(1, sw_count()):
			var index = sw_mod(current_special_weapon + i)
			if switch_to_specific_special(index):
				break
		
		switch_to_default_weapon()

func switch_to_default_weapon():
	for slot in core.get_node(core.turret_path).secondary_slots:
		slot.return_default_weapon()
	special_weapon_selected = false
	emit_signal("ammo_count_changed", special_ammo_counts, current_special_weapon)

func add_special_ammo(special_id):
	var weapon_dat = Client.SPECIAL_WEAPONS[special_id]
	special_ammo_counts[special_id] += weapon_dat.ammo_pickup_count
	if special_ammo_counts[special_id] > weapon_dat.max_ammo:
		special_ammo_counts[special_id] = weapon_dat.max_ammo
	if not special_weapon_selected:
		switch_to_specific_special(special_id)
	emit_signal("ammo_count_changed", special_ammo_counts, current_special_weapon)

func sw_count():
	return len(Client.SPECIAL_WEAPONS)

func sw_mod(index: int) -> int:
	var count = sw_count()
	return (count + index) % count
