extends Control

var player

onready var health_widget = $TopLeft/HealthWidget
onready var ammo_widget = $CenterTop/AmmoCounts

func add_player(player):
	var world = get_node("../World")
	self.player = player
	health_widget.max_value = player.get_node("Health").max_health
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
	else:
		health_widget.value = 0

func _process(delta):
	_update()
