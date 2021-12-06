extends MeshInstance

var obstacle

func _ready():
	get_node("../").connect("nav_ready", self, "_setup_obstacle")

func _setup_obstacle():
	var world = get_node("../")
	#obstacle = world.navigation.addBoxObstacle(
	#	global_transform.origin - Vector3(0, 1, 0),
	#	Vector3(8, 16, 8),
	#	global_transform.basis.get_euler().x
	#)
	obstacle = world.navigation.addCylinderObstacle(global_transform.origin - Vector3(0, 10, 0), 10, 30)
	world.navigation.rebuildChangedTiles()
	print(obstacle)
	
	world.redraw()

func _exit_tree():
	obstacle.destroy()