extends Node

var heat: int

signal heat_changed(new_heat)

export var minor_incursion_threshold: int
export var major_incursion_threshold: int
export var boss_incursion_threshold: int

func heat_percent() -> float:
	return float(heat) / float(boss_incursion_threshold)

func add_heat(amount: int):
	heat += amount
	if heat < 0:
		heat = 0
		return
	if heat > minor_incursion_threshold:
		do_minor_incursion()
	if heat > major_incursion_threshold:
		do_major_incursion()
	if heat > boss_incursion_threshold:
		do_boss_incursion()
		heat = boss_incursion_threshold
	emit_signal("heat_changed", heat)

func do_minor_incursion():
	pass

func do_major_incursion():
	pass

func do_boss_incursion():
	pass

