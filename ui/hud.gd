extends Control

var player

onready var health_widget = $TopLeft/HealthWidget
onready var energy_widget = $TopLeft/EnergyWidget
onready var heat_widget = $TopRight/HeatWidget

func add_player(player):
	var world = get_node("../World")
	self.player = player
	health_widget.max_value = player.get_node("Health").max_health
	energy_widget.max_value = player.get_node("Energy").max_energy
	_update()
	for objective in get_tree().get_nodes_in_group("objectives"):
		pass
		# TODO: Offscreen Indicators
		#var indicator = preload("OffscreenIndicator.tscn").instance()
		#indicator.setup(objective)
		#add_child(indicator)

func _update():
	if is_instance_valid(player):
		health_widget.value = player.get_node("Health").health
		energy_widget.value = player.get_node("Energy").energy
	else:
		health_widget.value = 0
		energy_widget.value = 0
	if is_instance_valid(Heat):
		heat_widget.value = Heat.heat

func _process(delta):
	_update()
