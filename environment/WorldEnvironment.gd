extends WorldEnvironment

var base_energy
var base_color

func _ready():
	Heat.connect("heat_changed", self, "_on_heat_change")
	Heat.connect("major_incursion_begun", self, "_on_major_incursion_begun")
	# environment.sun
	#base_energy = $CelestialSphere/Sun.light_energy
	#base_color = $CelestialSphere/Sun.light_color

func _on_major_incursion_begun():
	environment = preload("res://environment/IncursionWorld.tres")

func _on_heat_change(new_heat):
	pass
	# TODO: Lerp some stuff?
	# print("Heat Change")
	# $CelestialSphere/Sun.light_energy = lerp(
	#	base_energy,
	#	$CelestialSphere/Dark.light_energy,
	#	Heat.heat_percent()
	#)
	
	#$CelestialSphere/Sun.light_color = lerp(
	#	base_color,
	#	$CelestialSphere/Dark.light_color,
	#	Heat.heat_percent()
	#)
