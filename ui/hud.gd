extends Control

var player

func add_player(player: Vehicle):
	var world = get_node("../World")
	self.player = player
	$HealthWidget.max_value = player.get_node("Health").max_health
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
	else:
		$HealthWidget.value = 0

func _process(delta):
	_update()
