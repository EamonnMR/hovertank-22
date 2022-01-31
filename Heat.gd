extends Node

var heat: int

signal heat_changed(new_heat)

export var minor_incursion_threshold: int
export var major_incursion_threshold: int
export var boss_incursion_threshold: int

func add_heat(amount: int):
	heat += amount
	if heat > minor_incursion_threshold:
		do_minor_incursion()
	if heat > major_incursion_threshold:
		do_major_incursion()
	if heat > boss_incursion_threshold:
		do_boss_incursion()
	emit_signal("heat_changed", heat)

func do_minor_incursion():
	pass

func do_major_incursion():
	pass

func do_boss_incursion():
	pass

