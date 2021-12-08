extends Spatial

var obstacle
var world

func _ready():
	world = get_node("../")
	transform.origin = world.stick_to_ground(global_transform.origin)
	world.connect("nav_ready", self, "_setup_obstacle")

func _setup_obstacle():
	print("Setup Obstacle")
	var world = get_node("../")
	#obstacle = world.navigation.addBoxObstacle(
	#	global_transform.origin - Vector3(0, 1, 0),
	#	Vector3(8, 16, 8),
	#	global_transform.basis.get_euler().x
	#)
	obstacle = world.navigation.addCylinderObstacle(global_transform.origin - Vector3(0, 10, 0), 10, 30)
	world.navigation.rebuildChangedTiles()
	print("obstacle: ", obstacle)
	
	world.redraw()

func _exit_tree():
	obstacle.destroy()
