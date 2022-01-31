extends Control

var player

func add_player(player: Vehicle):
	var world = get_node("../World")
	self.player = player
	$HealthWidget.max_value = player.get_node("Health").max_health
	$EnergyWidget.max_value = player.get_node("Energy").max_energy
	_update()
	for objective in get_tree().get_nodes_in_group("objectives"):
		pass
		# TODO: Offscreen Indicators
		#var indicator = preload("OffscreenIndicator.tscn").instance()
		#indicator.setup(objective)
		#add_child(indicator)

func _update():
	if is_instance_valid(player):
		$HealthWidget.value = player.get_node("Health").health
		$EnergyWidget.value = player.get_node("Energy").energy
	else:
		$HealthWidget.value = 0
		$EnergyWidget.value = 0
	if is_instance_valid(Heat):
		$HeatWidget.value = Heat.heat

func _process(delta):
	_update()
