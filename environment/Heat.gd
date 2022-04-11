extends Node

var heat: int

# TODO: Each incursion level could be a node unto itself

signal heat_changed(new_heat)

signal minor_incursion_begun
signal major_incursion_begun
signal boss_incursion_begun

var current_incursion_level: int

export var minor_incursion_threshold: int
export var major_incursion_threshold: int
export var boss_incursion_threshold: int


var minor_incursion_active = false
var major_incursion_active = false
var boss_incursion_active = false

func heat_percent() -> float:
	return float(heat) / float(boss_incursion_threshold)

func add_heat(amount: int):
	heat += amount
	if heat < 0:
		heat = 0
		return
	if (heat > minor_incursion_threshold):
		if not minor_incursion_active:
			do_minor_incursion()
	if (heat > major_incursion_threshold):
		if not major_incursion_active:
			do_major_incursion()
	if (heat > boss_incursion_threshold):
		if not boss_incursion_active:
			do_boss_incursion()
		heat = boss_incursion_threshold
	emit_signal("heat_changed", heat)

func do_minor_incursion():
	minor_incursion_active = true
	emit_signal("minor_incursion_begun")

func do_major_incursion():
	major_incursion_active = true
	emit_signal("major_incursion_begun")

func do_boss_incursion():
	boss_incursion_active = true
	emit_signal("boss_incursion_begun")

func _on_MinorTimer_timeout():
	minor_incursion_active = false


func _on_BossTimer_timeout():
	boss_incursion_active = false


func _on_MajorTimer_timeout():
	major_incursion_active = false
