extends WorldEnvironment

var total_light
var light_factor

func _ready():
	Heat.connect("heat_changed", self, "_on_heat_change")
	total_light = $CelestialSphere/DirectionalLight.light_energy
	light_factor = total_light / Heat.boss_incursion_threshold
	
	

func _on_heat_change(new_heat):
	$CelestialSphere/DirectionalLight.light_energy = max(0, total_light - new_heat * light_factor )
